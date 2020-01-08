Trace-VstsEnteringInvocation $MyInvocation

$templatefolder = Get-VstsInput -Name TemplateFolder -Require

$ErrorActionPreference = 'SilentlyContinue'

Write-Host "Template Folder:      $templatefolder"
Import-Module "$PSScriptRoot\ps_modules\arm-ttk" -Verbose

$testOutput = @(Test-AzTemplate -TemplatePath \"$templatefolder\")

$testOutput 
if ($testOutput | ? {$_.Errors }) { exit 1 } else {   exit 0\n}