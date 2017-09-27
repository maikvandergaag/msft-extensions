$powerbiUrl = "https://api.powerbi.com/v1.0/myorg"

$powerBiBodyTemplate = @'
--{0}
Content-Disposition: form-data; name="fileData"; filename="{1}"
Content-Type: application/x-zip-compressed

{2}
--{0}--

'@

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
	$filebody = $encoding.GetString($fileBytes)

    $body = $powerBiBodyTemplate -f $boundary, $fileName, $encoding.GetString($fileBytes)
 

    $result = Invoke-API -Url $url -Method "Post" -AccessToken $AccessToken -Body $body -ContentType "multipart/form-data; boundary=--$boundary" 
    return $result
}

Export-ModuleMember -Function "Invoke-*"
Export-ModuleMember -Function "Get-*"
Export-ModuleMember -Function "Import-*"
Export-ModuleMember -Variable "powerbiUrl"
 