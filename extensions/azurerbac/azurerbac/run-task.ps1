# For more information on the VSTS Task SDK:
# https://github.com/Microsoft/vsts-task-lib

Trace-VstsEnteringInvocation $MyInvocation

Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
Initialize-Azure

$resourceGroupName = Get-VstsInput -Name ResourceGroupName -Require
$groups = Get-VstsInput -Name Groups
$users = Get-VstsInput -Name Users
$role = Get-VstsInput -Name AzureRoleAssignments
$action = Get-VstsInput -Name usergroup
$failonError = Get-VstsInput -Name FailonError
$userAction = Get-VstsInput -Name Action

Write-Host "Resource group: $resourceGroupName"
Write-Host "Groups: $groups"
Write-Host "Users: $users"
Write-Host "Role : $role"
Write-Host "Action : $action"
Write-Host "Fail On Error : $failonError"

Get-Module AzureRM -list | Select-Object Name,Version,Path


get-module -ListAvailable

if($userAction -eq "Add"){
	.\addroleassignment.ps1
}elseif($userAction -eq "Remove"){
	.\removeroleassignment.ps1
}




