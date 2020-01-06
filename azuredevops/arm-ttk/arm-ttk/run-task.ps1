Trace-VstsEnteringInvocation $MyInvocation

$templatefolder = Get-VstsInput -Name TemplateFolder -Require

Write-Host "Template Folder:      $templatefolder"

Install-Module Pester -Force -Scope CurrentUser

Import-Module "$PSScriptRoot\ps_modules\arm-ttk\arm-ttk.psd1"

Test-AzTemplate "$templatefolder"
