[CmdletBinding()]
param()
Trace-VstsEnteringInvocation $MyInvocation

#import powerbi module
Import-Module $PSScriptRoot\ps_modules\PowerBi
#import ADAL module
Import-Module $PSScriptRoot\ps_modules\ADAL.PS

try {
    # Get VSTS input values
	
	$authenticationType = Get-VstsInput -Name "AuthenticationType" -Require


	if($authenticationType -eq "User"){
		$connectedServiceName = Get-VstsInput -Name ConnectedServiceName
	}else{
		$connectedServiceName = Get-VstsInput -Name connectedServiceNameSP
	}

	
	$serviceEndpoint = Get-VstsEndpoint -Name $connectedServiceName -Require

	#connected service
	$userName =  $serviceEndpoint.Auth.Parameters.username
	$passWord = $serviceEndpoint.Auth.Parameters.password
	$clientId = $serviceEndpoint.Data.clientId

	if(!$clientId){
		$clientId = $serviceEndpoint.Auth.Parameters.servicePrincipalId
	}

	$clientSecret = $serviceEndpoint.Auth.Parameters.servicePrincipalKey
	$tenantId = $serviceEndpoint.Auth.Parameters.tenantId

	Write-Host "******************************"
	Write-Host "** Service Connection: $($connectedServiceName)"
	Write-Host "** TenantId: $($tenantId)"
	Write-Host "** ClientId: $($clientId)"
	Write-Host "******************************"

	if($password){
		$passWord = ConvertTo-SecureString $passWord -AsPlainText -Force
	}

	if($clientSecret){
		$secret = ConvertTo-SecureString $clientSecret -AsPlainText -Force
	}

	#parameters
	$filePattern = Get-VstsInput -Name PowerBIPath
	$workspaceName = Get-VstsInput -Name WorkspaceName
	$overwrite = Get-VstsInput -Name OverWrite -AsBool
	$create = Get-VstsInput -Name Create -AsBool
	$action= Get-VstsInput -Name Action -Require
	$dataset = Get-VstsInput -Name DatasetName
	$oldUrl = Get-VstsInput -Name OldUrl
	$newUrl = Get-VstsInput -Name NewUrl
	$oldServer = Get-VstsInput -Name OldServer
	$newServer = Get-VstsInput -Name NewServer
	$oldDatabase = Get-VstsInput -Name OldDatabase
	$groupObjectIds = Get-VstsInput -Name GroupObjectIds
	$newDatabase = Get-VstsInput -Name NewDatabase
	$accesRight = Get-VstsInput -Name Permission
	$users = Get-VstsInput -Name Users
	$datasourceType = Get-VstsInput -Name DatasourceType
	$updateAll = Get-VstsInput -Name UpdateAll -AsBool
	$ServicePrincipalsString = Get-VstsInput -Name ServicePrincipals 
	$ConnectionString = Get-VstsInput -Name ConnectionString

	.\run-task.ps1 -Username $userName -OldUrl $oldUrl -NewUrl $newUrl -OldServer $oldServer -DatasourceType $datasourceType -NewServer $newServer -OldDatabase $oldDatabase -NewDatabase $newDatabase -AccessRight $accesRight -Users $users -FilePattern $filePattern -Password $passWord -ClientId $clientId -WorkspaceName $workspaceName -Overwrite $overwrite -Create $create -Dataset $dataset -Action $action -UpdateAll $UpdateAll -ClientSecret $secret -TenantId $tenantId -ServicePrincipalString $ServicePrincipalsString -ConnectionString $ConnectionString -GroupObjectIds $groupObjectIds
}
finally {
    Trace-VstsLeavingInvocation $MyInvocation
}