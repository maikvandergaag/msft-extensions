[CmdletBinding()]
param()

# For more information on the VSTS Task SDK:
# https://github.com/Microsoft/vsts-task-lib
Trace-VstsEnteringInvocation $MyInvocation

Function Get-AADToken{
    Param(
        [parameter(Mandatory=$true)][string]$Username,
        [parameter(Mandatory=$true)][string]$Password,
        [parameter(Mandatory=$true)][guid]$ClientId,
        [parameter(Mandatory=$true)][string]$Resource
    )

    $authorityUrl = "https://login.microsoftonline.com/common/oauth2/authorize"

    ## load active directory client dll
    $typePath = $PSScriptRoot + "\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
    Add-Type -Path $typePath 

    Write-Verbose "Loaded the Microsoft.IdentityModel.Clients.ActiveDirectory.dll"

    Write-Verbose "Using authority: $authorityUrl"
    $authContext = New-Object -TypeName Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext -ArgumentList ($authorityUrl)
    $credential = New-Object -TypeName Microsoft.IdentityModel.Clients.ActiveDirectory.UserCredential -ArgumentList ($userName, $passWord)
    
    Write-Verbose "Trying to aquire token for resource: $resource"
    $authResult = $authContext.AcquireToken($resource,$clientId, $credential)

    Write-Verbose "Authentication Result retrieved for: $($authResult.UserInfo.GivenName)"
    return $authResult.AccessToken
}

Function Invoke-API{
    Param(
        [parameter(Mandatory=$true)][string]$Url,
        [parameter(Mandatory=$true)][string]$Method,
        [parameter(Mandatory=$true)]$AccessToken,
        [parameter(Mandatory=$false)][string]$Body,
        [parameter(Mandatory=$false)][string]$ContentType
    )

    $apiHeaders = @{
		'Content-Type'='application/json'
	    'Authorization'= "Bearer $AccessToken"
    }

	Write-Verbose "Trying to invoke api: $Url"

    if($Body){
        $result = Invoke-RestMethod -Uri $Url -Headers $apiHeaders -Method $Method -ContentType $ContentType -Body $Body
    }else{
        $result = Invoke-RestMethod -Uri $Url -Headers $apiHeaders -Method $Method
    }

    return $result
}

Function Get-PowerBiGroup{
    Param(
        [parameter(Mandatory=$true)][string]$GroupName,
        [parameter(Mandatory=$true)]$AccessToken
    )

    $groupsUrl = $powerbiUrl + "/groups"
    $result = Invoke-API -Url $groupsUrl -Method "Get" -AccessToken $token -Verbose
    $groups = $result.value

    $group = $null;
    if (-not [string]::IsNullOrEmpty($groupName)){

        Write-Verbose "Trying to find group: $groupName"		
        $groups = @($groups |? name -eq $groupName)
    
        if ($groups.Count -ne 0){
            $group = $groups[0]		
        }				
    }

    return $group
}

Function Get-PowerBiReport{
    Param(
        [parameter(Mandatory=$true)]$GroupId,
        [parameter(Mandatory=$true)]$AccessToken,
        [parameter(Mandatory=$true)]$ReportName
    )

    $url = $powerbiUrl + "/groups/$GroupId/reports"

    $result = Invoke-API -Url $url -Method "Get" -AccessToken $AccessToken -Verbose
    $reports = $result.value
	
    $report	= $null;
    if (-not [string]::IsNullOrEmpty($ReportName)){
        Write-Verbose "Trying to find report '$ReportName'"		

	    $reports = @($reports |? name -eq $ReportName)
	    if ($reports.Count -ne 0){
    	    $report = $reports[0]		
	    }			
    }	

    return $report
}

Function Import-PowerBiFile{
    Param(
        [parameter(Mandatory=$true)]$GroupId,
        [parameter(Mandatory=$true)]$AccessToken,
        [parameter(Mandatory=$true)]$Conflict,
        [parameter(Mandatory=$true)]$Path
    )

	$fileName = [IO.Path]::GetFileName($Path)
	$boundary = [guid]::NewGuid().ToString()
	$fileBytes = [System.IO.File]::ReadAllBytes($Path)
	$encoding = [System.Text.Encoding]::GetEncoding("iso-8859-1")
	$url = "$powerbiUrl/groups/$GroupId/imports?datasetDisplayName=$fileName&nameConflict=$Conflict"
	
	$template = @'
--{0}
Content-Disposition: form-data; name="fileData"; filename="{1}"
Content-Type: application/x-zip-compressed

{3}
--{0}--

'@

    $body = $template -f $boundary, $fileName, $contentType, $encoding.GetString($fileBytes)

    $result = Invoke-API -Url $url -Method "Post" -AccessToken $AccessToken -Body $body -ContentType "multipart/form-data; boundary=--$boundary" 
    return $result
}


try {
    # Get VSTS input values
    $userName = Get-VstsInput -Name Username -Require
	$filePattern = Get-VstsInput -Name PowerBIPath -Require
	$passWord = Get-VstsInput -Name Password -Require
	$clientId = Get-VstsInput -Name ClientId -Require
	$groupName = Get-VstsInput -Name GroupName -Require
	$overwrite = Get-VstsInput -Name OverWrite -Require

	$resourceUrl = "https://analysis.windows.net/powerbi/api"
	$powerbiUrl = "https://api.powerbi.com/v1.0/myorg"

	Write-Host "Publishing PowerBI FIle: $filePattern, in group: $groupName with user: $userName"

    #AADToken
	Write-Host "Getting AAD Token for user: $userName"
	$token = Get-AADToken -username $userName -Password $passWord -clientId $clientId -resource $resourceUrl -Verbose

	#Current groups
	Write-Host "Getting PowerBI group properties; $groupName"
	$group = Get-PowerBiGroup -GroupName $groupName -AccessToken $token -Verbose

	$searchedFiles = Get-ChildItem $filePattern
	foreach($foundFile in $searchedFiles){
		$directory = $foundFile.DirectoryName
		$file = $foundFile.Name

		$filePath = "$directory\$file"
		Write-Host "Trying to publish PowerBI File: $filePath"

		#Check for exisiting report
		$fileNamewithoutextension = [IO.Path]::GetFileNameWithoutExtension($filePath)
		Write-Host "Checking for existing Reports with the name: $fileNamewithoutextension"
	
		$report = Get-PowerBiReport -GroupId $group.id -AccessToken $token -ReportName $fileNamewithoutextension -Verbose

		$nameConflict = "Abort"
		if($report){
			Write-Verbose "Reports exisits"
			if($overwrite){
				Write-Verbose "Reports exisits and needs to be overwritten"
				$nameConflict = "Overwrite"
			}
		}

		Write-Verbose $group.id
		Write-Verbose $token
		Write-Verbose $filePath
		Write-Verbose $nameConflict

		#Import PowerBi file
		Write-Host "Importing PowerBI File"
		Import-PowerBiFile -GroupId $group.id -AccessToken $token -Path $filePath -Conflict $nameConflict -Verbose
	}

} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}