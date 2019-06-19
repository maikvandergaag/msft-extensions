Trace-VstsEnteringInvocation $MyInvocation

$resourceGroupName = Get-VstsInput -Name ResourceGroupName -Require
$groups = Get-VstsInput -Name Groups
$users = Get-VstsInput -Name Users
$applications = Get-VstsInput -Name Applications
$role = Get-VstsInput -Name AzureRoleAssignments
$action = Get-VstsInput -Name usergroup
$failonError = Get-VstsInput -Name FailonError
$userAction = Get-VstsInput -Name Action

Write-Host "Resource group:      $resourceGroupName"
Write-Host "Groups:              $groups"
Write-Host "Users:               $users"
Write-Host "Applications:        $applications"
Write-Host "Role :               $role"
Write-Host "Action :             $action"
Write-Host "Fail On Error :      $failonError"

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

	if($userAction -eq "Add"){
		.\addroleassignment.ps1
	}elseif($userAction -eq "Remove"){
		.\removeroleassignment.ps1
	}
}
finally {
	  Trace-VstsLeavingInvocation $MyInvocation
}



