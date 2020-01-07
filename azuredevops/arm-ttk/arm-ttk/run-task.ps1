Trace-VstsEnteringInvocation $MyInvocation

$templatefolder = Get-VstsInput -Name TemplateFolder -Require

$ErrorActionPreference = 'SilentlyContinue'

Write-Host "Template Folder:      $templatefolder"
Import-Module Pester
Import-Module "$PSScriptRoot\ps_modules\arm-ttk"

Write-Host "Testing ARM Template"
$output = Test-AzTemplate "$templatefolder"

Write-Host "The ouput of the test is:"
$output
