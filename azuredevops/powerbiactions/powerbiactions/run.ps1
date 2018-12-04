[CmdletBinding()]
param()
Trace-VstsEnteringInvocation $MyInvocation

#import powerbi module
Import-Module $PSScriptRoot\ps_modules\PowerBi

try {
    # Get VSTS input values
	
	$connectedServiceName = Get-VstsInput -Name ConnectedServiceName
	$serviceEndpoint = Get-VstsEndpoint -Name $connectedServiceName -Require

	#connected service
	$userName =  $serviceEndpoint.Auth.Parameters.Username
	$passWord = $serviceEndpoint.Auth.Parameters.Password
	$clientId = $serviceEndpoint.Data.Parameters.ClientId

	#parameters
	$filePattern = Get-VstsInput -Name PowerBIPath
	$workspaceName = Get-VstsInput -Name WorkspaceName
	$overwrite = Get-VstsInput -Name OverWrite
	$create = Get-VstsInput -Name Create
	$action= Get-VstsInput -Name Action -Require
	$dataset = Get-VstsInput -Name Dataset
	$oldUrl = Get-VstsInput -Name OldUrl
	$newUrl = Get-VstsInput -Name NewUrl
	$oldServer = Get-VstsInput -Name OldServer
	$newServer = Get-VstsInput -Name NewServer
	$oldDatabase = Get-VstsInput -Name OldDatabase
	$newDatabase = Get-VstsInput -Name -NewDatabase
	$accesRight = "Admin"
	$users = Get-VstsInput -Name -Users
	$datasourceType = Get-VstsInput -Name DatasourceType

	#.\run-task.ps1 -Username $userName -FilePattern $filePattern -Password $passWord -ClientId $clientId -GroupName $groupName -Overwrite $overwrite -Connectionstring $connectionstring -Create $create -Dataset $dataset -Action $action
	.\run-task.ps1 -Username $userName -OldUrl $oldUrl -NewUrl $newUrl -OldServer $oldServer -DatasourceType $datasourceType -NewServer $newServer -OldDatabase $oldDatabase -NewDatabase $newDatabase -AccessRight $accesRight -Users $users -FilePattern $filePattern -Password $passWord -ClientId $clientId -WorkspaceName $workspaceName -Overwrite $overwrite -Create $create -Dataset $dataset -Action $action
}
finally {
    Trace-VstsLeavingInvocation $MyInvocation
}