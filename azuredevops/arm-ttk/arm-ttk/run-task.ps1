Write-Output "** Starting ARM Template test **"

Trace-VstsEnteringInvocation $MyInvocation
$templatefolder = Get-VstsInput -Name TemplateFolder -Require

$moduleFolder = "$PSScriptRoot\ps_modules\arm-ttk\arm-ttk.psd1"

Write-Output "Importing module from the directory: $moduleFolder"
Import-Module "$moduleFolder" -Verbose

Write-Output "Testing the the ARM templates in the folder"
$testOutput = @(Test-AzTemplate -TemplatePath $templatefolder)

$testOutput 

if ($testOutput | Where-Object {$_.Errors }) {
   Write-Output "## Problems occured during test execution!"
   exit 1 
} else {
   Write-Output "## Test execution went perfectly!"
   exit 0
} 