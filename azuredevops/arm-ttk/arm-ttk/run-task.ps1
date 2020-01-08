Trace-VstsEnteringInvocation $MyInvocation

$templatefolder = Get-VstsInput -Name TemplateFolder -Require

Write-Host "Importing ARM TTK Module"
Import-Module "$PSScriptRoot\ps_modules\arm-ttk" -Verbose

Write-Host "## Template Folder:      $templatefolder"
$testOutput = @(Test-AzTemplate $templatefolder )

$testOutput 
if ($testOutput | ? {$_.Errors }) { exit 1 } else {   exit 0\n}