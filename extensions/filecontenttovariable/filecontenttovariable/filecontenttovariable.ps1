[CmdletBinding()]
param()

Trace-VstsEnteringInvocation $MyInvocation	

try {
    $path = Get-VstsInput -Name FilePath -Require
	$variable = Get-VstsInput -Name VariableName -Require

	Write-Host "Setting '$variable' to content of the file '$path'."

    $fileString = Get-Content $path -Raw

    Write-Host "##vso[task.setvariable variable=$($variable);]$fileString"

}finally {
    Trace-VstsLeavingInvocation $MyInvocation
}