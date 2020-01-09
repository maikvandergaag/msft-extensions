Write-Output "** Starting ARM Template test **"


Trace-VstsEnteringInvocation $MyInvocation
$templatefolder = Get-VstsInput -Name TemplateFolder -Require

$ErrorActionPreference = "Continue"

$moduleFolder = "$PSScriptRoot\ps_modules\arm-ttk\arm-ttk.psd1"

Write-Output "Importing module from the directory: $moduleFolder"

Import-Module "$moduleFolder" -Verbose

Write-Output = "Testing the the ARM templates in the folder"

$testOutput = @(Test-AzTemplate -TemplatePath $templatefolder)

$testOutput 

if ($testOutput | ? {$_.Errors }) {
   exit 1 
} else {
   exit 0
} 