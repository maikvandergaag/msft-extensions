Trace-VstsEnteringInvocation $MyInvocation

$resourceGroupName = Get-VstsInput -Name ResourceGroupName -Require
$Key = Get-VstsInput -Name Key
$Value = Get-VstsInput -Name Value
$action = Get-VstsInput -Name Action

Write-Host "Resource group: $resourceGroupName"
Write-Host "Key: $key"
Write-Host "Value: $value"
Write-Host "Action : $action"

. "$PSScriptRoot\Utility.ps1"
$targetAzurePs = Get-RollForwardVersion -azurePowerShellVersion $targetAzurePs

$authScheme = ''
try
{
    $serviceNameInput = Get-VstsInput -Name ConnectedServiceNameSelector -Default 'ConnectedServiceName'
    $serviceName = Get-VstsInput -Name $serviceNameInput -Default (Get-VstsInput -Name DeploymentEnvironmentName)
    if (!$serviceName)
    {
            Get-VstsInput -Name $serviceNameInput -Require
    }

    $endpoint = Get-VstsEndpoint -Name $serviceName -Require

    if($endpoint)
    {
        $authScheme = $endpoint.Auth.Scheme 
    }

     Write-Verbose "AuthScheme $authScheme"
}
catch
{
   $error = $_.Exception.Message
   Write-Verbose "Unable to get the authScheme $error" 
}

Update-PSModulePathForHostedAgent -targetAzurePs $targetAzurePs -authScheme $authScheme

try {
    # Initialize Azure.
    Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
    Initialize-Azure -azurePsVersion $targetAzurePs -strict   

	if($action -eq "Add"){
	    Write-Host "Adding the $key to the tags"
		.\addtags.ps1
	}elseif($action -eq "Remove"){
		Write-Host "Removing the $key from the tags"
		.\removetags.ps1
	}
}
finally {
	  Trace-VstsLeavingInvocation $MyInvocation
}



