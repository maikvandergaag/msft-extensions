Trace-VstsEnteringInvocation $MyInvocation

$templatefolder = Get-VstsInput -Name TemplateFolder -Require

Write-Host "Template Folder:      $templatefolder"

Import-Module "$PSScriptRoot\ps_modules\arm-tkk\arm-ttk.psd1"

Test-AzTempate $templatefolder