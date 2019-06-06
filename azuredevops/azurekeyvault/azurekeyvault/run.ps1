Trace-VstsEnteringInvocation $MyInvocation
Write-Host "Starting up extension"


$KeyVaultName = Get-VstsInput -Name KeyVaultName -Require
$Secret = Get-VstsInput -Name Secret
$CertificateFile = Get-VstsInput -Name CertificateFile
$CertificateName = Get-VstsInput -Name CertificateName
$SecretName = Get-VstsInput -Name SecretName
$ObjectId = Get-VstsInput -Name ObjectId
$PermissionsToKeys = Get-VstsInput -Name PermissionsToKeys
$PermissionsToSecrets = Get-VstsInput -Name PermissionsToSecrets
$PermissionsToCertificates = Get-VstsInput -Name PermissionsToCertificates
$PermissionsToStorage = Get-VstsInput -Name PermissionsToStorage
$Action = Get-VstsInput -Name Action
$VariableName = Get-VstsInput -Name VariableName
$CertificatePassword = Get-VstsInput -Name CertificatePassword
$Overwrite = Get-VstsInput -Name Overwrite -AsBool

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

	.\run-task.ps1 -KeyVaultName $KeyVaultName -Secret $Secret -CertificateFile $CertificateFile -CertificateName $CertificateName -SecretName $SecretName -ObjectId $ObjectId -Action $Action -VariableName $VariableName -CertificatePassword $CertificatePassword -PermissionsToKeys $PermissionsToKeys -PermissionsToSecrets $PermissionsToSecrets -PermissionsToCertificates $PermissionsToCertificates  -PermissionsToStorage $PermissionsToStorage -Overwrite $Overwrite
}
finally {
	  Trace-VstsLeavingInvocation $MyInvocation
}



