$powerbiUrl = "https://api.powerbi.com/v1.0"
$resourceUrl = "https://analysis.windows.net/powerbi/api"

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
	#$credential = New-Object -TypeName Microsoft.IdentityModel.Clients.ActiveDirectory.ClientCredential -ArgumentList ($clientId, $passWord)
    
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

    $groupsUrl = $powerbiUrl + '/myorg/groups'
    $result = Invoke-API -Url $groupsUrl -Method "Get" -AccessToken $AccessToken -Verbose
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

Function Update-ConnectionStringDirectQuery{
    Param(
        [parameter(Mandatory=$true)]$GroupPath,
        [parameter(Mandatory=$true)]$AccessToken,
        [parameter(Mandatory=$true)]$DatasetName,
        [parameter(Mandatory=$true)]$ConnectionString
    )

    $set = Get-PowerBiDataSet -GroupPath $GroupPath -AccessToken $AccessToken -Name $DatasetName 
    $setId = $set.id

    $body = @{
		connectionString = $ConnectionString
	} | ConvertTo-Json
    
    $url = $powerbiUrl + "$GroupPath/datasets/$setId/Default.SetAllConnections"
     
    $result = Invoke-API -Url $url -Method "Post" -AccessToken $AccessToken -Body $body -ContentType "application/json"
    $reports = $result.value
}

Function Get-PowerBiReport{
    Param(
        [parameter(Mandatory=$true)]$GroupPath,
        [parameter(Mandatory=$true)]$AccessToken,
        [parameter(Mandatory=$true)]$ReportName
    )

    $url = $powerbiUrl + $GroupPath + "/reports"

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

Function Get-PowerBiDataSet{
    Param(
        [parameter(Mandatory=$true)]$GroupPath,
        [parameter(Mandatory=$true)]$AccessToken,
        [parameter(Mandatory=$true)]$Name
    )
    
    $url = $powerbiUrl + "$GroupPath/datasets"
    $result = Invoke-API -Url $url -Method "Get" -AccessToken $AccessToken -Verbose
    $sets = $result.value
	
    $set = $null;
    if (-not [string]::IsNullOrEmpty($Name)){
        Write-Verbose "Trying to find dataset '$Name'"		

	    $sets = @($sets |? name -eq $Name)
	    if ($sets.Count -ne 0){
    	    $set = $sets[0]		
	    }			
    }	

    return $set
}

Function Create-WorkSpace{
   Param(
        [parameter(Mandatory=$true)]$GroupName,
        [parameter(Mandatory=$true)]$AccessToken
    )
	$url = $powerbiUrl + "/myorg/groups"

	$body = @{
		name = $GroupName
	} | ConvertTo-Json

	$result = Invoke-API -Url $url -Method "Post" -AccessToken $AccessToken -Body $body -ContentType "application/json"
    
    Write-Host "Group: $GroupName created!"
	Write-Output $result
}

Function Import-PowerBiFile{
    Param(
        [parameter(Mandatory=$true)]$GroupPath,
        [parameter(Mandatory=$true)]$AccessToken,
        [parameter(Mandatory=$true)]$Conflict,
        [parameter(Mandatory=$true)]$Path
    )

	$fileName = [IO.Path]::GetFileName($Path)
	$boundary = [guid]::NewGuid().ToString()
	$fileBytes = [System.IO.File]::ReadAllBytes($Path)
	$encoding = [System.Text.Encoding]::GetEncoding("iso-8859-1")
	$url = $powerbiUrl + "$GroupPath/imports?datasetDisplayName=$fileName&nameConflict=$Conflict"
	$filebody = $encoding.GetString($fileBytes)

    $body = $powerBiBodyTemplate -f $boundary, $fileName, $encoding.GetString($fileBytes)
 

    $result = Invoke-API -Url $url -Method "Post" -AccessToken $AccessToken -Body $body -ContentType "multipart/form-data; boundary=--$boundary" 
    return $result
}

Export-ModuleMember -Function "Invoke-*"
Export-ModuleMember -Function "Get-*"
Export-ModuleMember -Function "Update-*"
Export-ModuleMember -Function "Import-*"
Export-ModuleMember -Function "Create-*"
Export-ModuleMember -Variable "powerbiUrl"
Export-ModuleMember -Variable "resourceUrl"
 