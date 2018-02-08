[CmdletBinding()]
param()

# For more information on the VSTS Task SDK:
# https://github.com/Microsoft/vsts-task-lib
Trace-VstsEnteringInvocation $MyInvocation

Import-Module $PSScriptRoot\ps_modules\PowerBi

try {
    # Get VSTS input values
    $userName = Get-VstsInput -Name Username -Require
	$filePattern = Get-VstsInput -Name PowerBIPath -Require
	$passWord = Get-VstsInput -Name Password -Require
	$clientId = Get-VstsInput -Name ClientId -Require
	$groupName = Get-VstsInput -Name GroupName -Require
	$overwrite = Get-VstsInput -Name OverWrite -Require
	
	
	.\publishpowerbi.ps1

	} 
finally {
    Trace-VstsLeavingInvocation $MyInvocation
}