[CmdletBinding()]
param()

# For more information on the VSTS Task SDK:
# https://github.com/Microsoft/vsts-task-lib

#Login-AzureRmAccount 
$resourceGroupName = "mpn-rg-ddos"

$groups = "Release Management"
$users = "m345@familie-vandergaag.nl, mdamadm"
$role = "Contributor"
$action = "Users"
$failonError = $true

Write-Host "Resource group: $resourceGroupName"
Write-Host "Groups: $groups"
Write-Host "Users: $users"
Write-Host "Role : $role"

.\addroleassigment.ps1
