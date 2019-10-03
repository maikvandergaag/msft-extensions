[CmdletBinding()]
param()
Trace-VstsEnteringInvocation $MyInvocation

#import powerbi module
Import-Module $PSScriptRoot\ps_modules\PowerBi
#import ADAL module
Import-Module $PSScriptRoot\ps_modules\ADAL.PS

try {
    # Get VSTS input values
	
	$connectedServiceName = Get-VstsInput -Name ConnectedServiceName
	$serviceEndpoint = Get-VstsEndpoint -Name $connectedServiceName -Require

	#connected service
	$userName =  $serviceEndpoint.Auth.Parameters.username
	$passWord = $serviceEndpoint.Auth.Parameters.password
	$clientId = $serviceEndpoint.Data.clientId

	Write-Host $serviceEndpoint.Data
	Write-Host $serviceEndpoint.Auth.Parameters

	Write-Host "******************************"
	Write-Host "** Service Connection: $($connectedServiceName)"
	Write-Host "** Username: $($userName)"
	Write-Host "** Password: $($passWord)"
	Write-Host "** ClientId: $($clientId)"
	Write-Host "******************************"

	$passWord = ConvertTo-SecureString $passWord -AsPlainText -Force

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
	$newDatabase = Get-VstsInput -Name NewDatabase
	$accesRight = "Admin"
	$users = Get-VstsInput -Name Users
	$datasourceType = Get-VstsInput -Name DatasourceType
	$updateAll = Get-VstsInput -Name UpdateAll -AsBool



	#.\run-task.ps1 -Username $userName -FilePattern $filePattern -Password $passWord -ClientId $clientId -GroupName $groupName -Overwrite $overwrite -Connectionstring $connectionstring -Create $create -Dataset $dataset -Action $action
	.\run-task.ps1 -Username $userName -OldUrl $oldUrl -NewUrl $newUrl -OldServer $oldServer -DatasourceType $datasourceType -NewServer $newServer -OldDatabase $oldDatabase -NewDatabase $newDatabase -AccessRight $accesRight -Users $users -FilePattern $filePattern -Password $passWord -ClientId $clientId -WorkspaceName $workspaceName -Overwrite $overwrite -Create $create -Dataset $dataset -Action $action -UpdateAll $UpdateAll
}
finally {
    Trace-VstsLeavingInvocation $MyInvocation
}