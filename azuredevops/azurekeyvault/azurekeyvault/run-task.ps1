[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)][String]$KeyVaultName,
    [Parameter(Mandatory = $false)][String]$Secret,
    [Parameter(Mandatory = $false)][String]$CertificateFile,
    [Parameter(Mandatory = $false)][String]$CertificateName,
    [Parameter(Mandatory = $false)][String]$SecretName,
    [Parameter(Mandatory = $false)][String]$ObjectId,
    [Parameter(Mandatory = $false)][String]$PermissionsToKeys,
    [Parameter(Mandatory = $false)][String]$PermissionsToSecrets,
    [Parameter(Mandatory = $false)][String]$PermissionsToCertificates,
    [Parameter(Mandatory = $false)][String]$PermissionsToStorage,
    [Parameter(Mandatory = $false)][String]$Action,
    [Parameter(Mandatory = $false)][String]$VariableName,
    [Parameter(Mandatory = $false)][String]$CertificatePassword,
    [Parameter(Mandatory = $false)][bool]$Overwrite
)

Write-Host "******************************"
Write-Host "** Azure Key Vault Name: $($KeyVaultName)"
Write-Host "** Action: $($Action)"
Write-Host "******************************"

#import powerbi module
Import-Module $PSScriptRoot\ps_modules\KeyVault

#Check existance of the KeyVault
$KeyVault = Get-AzureRmKeyVault -VaultName $KeyVaultName -ErrorAction SilentlyContinue -ErrorVariable KeyVaultError
if ($KeyVault -eq $null) {
    Write-Error "KeyVault '$($KeyVaultName)' cannot be accessed. Error: $KeyVaultError";
    Write-Host "##vso[task.logissue type=error;] KeyVault '$($KeyVaultName)' cannot be accessed. Error: $KeyVaultError";
    Exit;
} 

if ($Action -eq "GetSecret") {

    Write-Host "Trying to retrieve a secret from the Azure Key Vault"
    Write-Host "******************************"
    Write-Host "** SecretName: $($SecretName)"
    Write-Host "** Variable name: $($VariableName)"
    Write-Host "** Overwrite: $($Overwrite)"
    Write-Host "******************************"

    Get-KeyVaultSecret -KeyVaultName $KeyVaultName -SecretName $SecretName -VariableName $VariableName
}
elseif ($Action -eq "SetSecret") {
    Write-Host "Trying to set a secret in the Azure Key Vault"
    Write-Host "******************************"
    Write-Host "** Secret: $(if (![System.String]::IsNullOrWhiteSpace($Secret)) { '***'; } else { '<not present>'; })"
    Write-Host "** SecretName: $($SecretName)"
    Write-Host "** Variable name: $($VariableName)"
    Write-Host "** Overwrite: $($Overwrite)"
    Write-Host "******************************"
    
    Set-KeyVaultSecret -KeyVaultName $KeyVaultName -SecretName $SecretName -SecretValue $Secret -VariableName $VariableName -Overwrite $Overwrite
}
elseif ($Action -eq "RemoveSecret") {
    Write-Host "Trying to remove a secret from the Azure Key Vault"
    Write-Host "******************************"
    Write-Host "** SecretName: $($SecretName)"
    Write-Host "******************************"
    
    Remove-KeyVaultSecret -SecretName $SecretName -KeyVaultName $KeyVaultName
}
elseif ($Action -eq "AddAccessPolicy") {
    Write-Host "Trying to add a access policy to the Azure Key Vault"
    Write-Host "******************************"
    Write-Host "** ObjectId: $($ObjectId)"
    Write-Host "** Permissions to Keys: $($PermissionsToKeys)"
    Write-Host "** Permissions to Secrets: $($PermissionsToSecrets)"
    Write-Host "** Permissions to Certificate: $($PermissionsToCertificates)"
    Write-Host "** Permissions to Storage: $($PermissionsToStorage)"
    Write-Host "******************************"
    
    Add-KeyVaultPolicy -KeyVaultName $KeyVaultName -ObjectId $ObjectId -PermissionsToKeys $PermissionsToKeys -PermissionsToSecrets $PermissionsToSecrets -PermissionsToCertificates $PermissionsToCertificates -PermissionsToStorage $PermissionsToStorage
}
elseif ($Action -eq "RemoveAccessPolicy") {
    Write-Host "Trying to remove a access policy in the Azure Key Vault"
    Write-Host "******************************"
    Write-Host "** ObjectId: $($ObjectId)"
    Write-Host "******************************"
    
    Remove-KeyVaultPolicy -KeyVaultName $KeyVaultName -ObjectId $ObjectId
}
elseif ($Action -eq "ImportCertificate") {
    Write-Host "Trying to import a certificate in the Azure Key Vault"
    Write-Host "******************************"
    Write-Host "** CertificateFile: $($CertificateFile)"
    Write-Host "** CertificateName: $($CertificateName)"
    Write-Host "** Variable name: $($VariableName)"
    Write-Host "** CertificatePassword: $(if (![System.String]::IsNullOrWhiteSpace($CertificatePassword)) { '***'; } else { '<not present>'; })"
    Write-Host "** Overwrite: $($Overwrite)"
    Write-Host "******************************"
    
    Import-KeyVaultCertificate -KeyVaultName $KeyVaultName -CertificateName $CertificateName -CertificatePath $CertificateFile -CertificatePassword $CertificatePassword -VariableName $VariableName -Overwrite $Overwrite
}
elseif ($Action -eq "GetCertificateUri") {
    Write-Host "Trying to get a certificate uri from the Azure Key Vault"
    Write-Host "******************************"
    Write-Host "** CertificateName: $($CertificateName)"
    Write-Host "** Variable name: $($VariableName)"
    Write-Host "******************************"
    
    Get-KeyVaultCertificateUrl -KeyVaultName $KeyVaultName -CertificateName $CertificateName -VariableName $VariableName
}


