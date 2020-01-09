Trace-VstsEnteringInvocation $MyInvocation
$templatefolder = Get-VstsInput -Name TemplateFolder -Require

$ErrorActionPreference = "Continue"

Import-Module $PSScriptRoot\ps_modules\arm-ttk\arm-ttk.psd1 -Verbose
$testOutput = @(Test-AzTemplate -TemplatePath $templatefolder)

$testOutput 

if ($testOutput | ? {$_.Errors }) {
   exit 1 
} else {
   exit 0
} 