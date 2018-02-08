[CmdletBinding()]
param()

# For more information on the VSTS Task SDK:
# https://github.com/Microsoft/vsts-task-lib

Login-AzureRmAccount 
$resourceGroupName = "MSFT-FunctionRelease"

$groups = "Release Management"
$users = "maik@familie-vandergaag.nl,maikvandergaag_outlook.com#EXT#@familievandergaag.onmicrosoft.com"
$role = "Contributor"
$action = "Groups"
$BreakonException = $true

Write-Host "Resource group: $resourceGroupName"
Write-Host "Groups: $groups"
Write-Host "Users: $users"
Write-Host "Role : $role"

.\addroleassigment.ps1
