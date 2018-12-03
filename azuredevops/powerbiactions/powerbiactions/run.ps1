[CmdletBinding()]
param()
Trace-VstsEnteringInvocation $MyInvocation

#import powerbi module
Import-Module $PSScriptRoot\ps_modules\PowerBi

try {
    # Get VSTS input values
    $userName = Get-VstsInput -Name Username -Require
	$filePattern = Get-VstsInput -Name PowerBIPath
	$passWord = Get-VstsInput -Name Password -Require
	$clientId = Get-VstsInput -Name ClientId -Require
	$groupName = Get-VstsInput -Name GroupName
	$overwrite = Get-VstsInput -Name OverWrite
	$connectionstring = Get-VstsInput -Name ConnectionString
	$create = Get-VstsInput -Name Create
	$action= Get-VstsInput -Name Action -Require
    $dataset = Get-VstsInput -Name Dataset

    .\run-task.ps1 -Username $userName -FilePattern $filePattern -Password $passWord -ClientId $clientId -GroupName $groupName -Overwrite $overwrite -Connectionstring $connectionstring -Create $create -Dataset $dataset -Action $action
}
finally {
    Trace-VstsLeavingInvocation $MyInvocation
}