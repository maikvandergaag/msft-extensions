Write-Output "** Starting ARM Template test **"

Trace-VstsEnteringInvocation $MyInvocation
$templatefolder = Get-VstsInput -Name TemplateFolder -Require

$moduleFolder = "$PSScriptRoot\ps_modules\arm-ttk\arm-ttk.psd1"

Write-Output "Importing module from the directory: $moduleFolder"
Import-Module "$moduleFolder" -Verbose

Write-Output "Testing the the ARM templates in the folder"
$testOutput = @(Test-AzTemplate -TemplatePath $templatefolder)

$testOutput 

$ErrorActionPreference = "Stop"

if ($testOutput | Where-Object {$_.Errors }) {
   Write-Error "## Problems occured during test execution!"
} else {
   Write-Output "## Test execution went perfectly!"
} 