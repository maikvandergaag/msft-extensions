$powerbiUrl = "https://api.powerbi.com/v1.0/myorg"
$resourceUrl = "https://analysis.windows.net/powerbi/api"


Function Get-Token {
    Param(
        [parameter(Mandatory=$true)][string]$Username,
        [parameter(Mandatory=$true)][string]$Password,
        [parameter(Mandatory=$true)][guid]$ClientId,
        [parameter(Mandatory=$true)][guid]$TenantId
    )
    
    $Url = "https://login.microsoftonline.com/$TenantId/oauth2/token"
    $Body = "grant_type=password&resource=$resourceUrl&username=$Username&password=$Password&client_id=$ClientId"

    $apiHeaders = @{
		'Content-Type'='application/x-www-form-urlencoded'
	    'charset'= 'utf-8'
    }

    $result = Invoke-RestMethod -Uri $Url -Headers $apiHeaders -Method "Post" -Body $Body
    $json = $result | ConvertTo-json | ConvertFrom-json
    $token = $json.access_token

    return $token
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


Function Set-Parameters{
    Param(
        [parameter(Mandatory=$true)]$GroupId,
        [parameter(Mandatory=$true)]$DatasetId,
        [parameter(Mandatory=$true)]$AccessToken,
        [parameter(Mandatory=$true)]$ParamsArray
    )

	$url = "$powerbiUrl/groups/$GroupId/datasets/$DatasetId/UpdateParameters"
	
    Write-Host "Updating parameters - $ParamsArray"

    $body = '{"updateDetails": ' + $ParamsArray + '}'

    $result = Invoke-API -Url $url -Method "Post" -AccessToken $AccessToken -Body $body -ContentType "application/json"
    return $result
}

Function Set-TriggerRefresh{
    Param(
        [parameter(Mandatory=$true)]$GroupId,
        [parameter(Mandatory=$true)]$DatasetId,
        [parameter(Mandatory=$true)]$AccessToken
    )

    $url = "$powerbiUrl/groups/$GroupId/datasets/$DatasetId/refreshes"

    Write-Host "Refreshing Dataset: $DatasetId of Group: $GroupId"

    $result = Invoke-API -Url $url -Method "Post" -AccessToken $AccessToken -ContentType "application/json"

    return $result
}

Export-ModuleMember -Function "Get-*"
Export-ModuleMember -Function "Set-*"
Export-ModuleMember -Variable "powerbiUrl"
Export-ModuleMember -Variable "resourceUrl"
 