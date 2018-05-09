[CmdletBinding()]
param()

Import-Module $PSScriptRoot\ps_modules\VstsTaskSdk

Write-Host "Script root $PSScriptRoot"

# For more information on the VSTS Task SDK:
# https://github.com/Microsoft/vsts-task-lib
Trace-VstsEnteringInvocation $MyInvocation

Write-Verbose $PSScriptRoot

Import-Module $PSScriptRoot\ps_modules\PowerBi
# Import-Module .\ps_modules\PowerBi

try {
    # Get VSTS input values
    $userName = Get-VstsInput -Name Username -Require
	$passWord = Get-VstsInput -Name Password -Require
	$clientId = Get-VstsInput -Name ClientId -Require
	$tenantId = Get-VstsInput -Name TenantId -Require
	$groupId = Get-VstsInput -Name GroupId -Require
	$datasetId = Get-VstsInput -Name DatasetId -Require
	$paramsArray = Get-VstsInput -Name ParamsArray -Require
	$refresh = Get-VstsInput -Name Refresh -Require

	.\setpowerbidatasetparameters.ps1

	} 
finally {
    Trace-VstsLeavingInvocation $MyInvocation
}