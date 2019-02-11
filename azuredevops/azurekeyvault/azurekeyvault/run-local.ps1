[CmdletBinding()]
param()

$KeyVaultName = "pms-keyvault"
$Secret = "Test"
$CertificateFile = "D:\Source\promanagement\pmonline\PMOnline\src\PM.STS\PMWebSTS.pfx"
$CertificateName = "sts"
$SecretName = "Test"
$ObjectId = "0f0969ef-a298-4db5-82b1-c304b9dcda0c"
#decrypt,encrypt,unwrapKey,wrapKey,verify,sign,get,list,update,create,import,delete,backup,restore,recover,purge
$PermissionsToKeys = "decrypt,encrypt,unwrapKey,wrapKey,verify,sign,get,list,update,create,import,delete,backup,restore,recover,purge"
#get,list,set,delete,backup,restore,recover,purge
$PermissionsToSecrets = "get,list,set,delete,backup,restore,recover,purge"
#get,list,delete,create,import,update,managecontacts,getissuers,listissuers,setissuers,deleteissuers,manageissuers,recover,purge,backup,restore
$PermissionsToCertificates = "get,list,delete,create,import,update,managecontacts,getissuers,listissuers,setissuers,deleteissuers,manageissuers,recover,purge,backup,restore"
#get,list,delete,set,update,regeneratekey,getsas,listsas,deletesas,setsas,recover,backup,restore,purge
$PermissionsToStorage = ""
$Action = "ImportCertificate"
$VariableName = "Test"
$CertificatePassword = "pass@word1" 
$Overwrite = $true

.\run-task.ps1 -KeyVaultName $KeyVaultName -Secret $Secret -CertificateFile $CertificateFile -CertificateName $CertificateName -SecretName $SecretName -ObjectId $ObjectId -Action $Action -VariableName $VariableName -CertificatePassword $CertificatePassword -PermissionsToKeys $PermissionsToKeys -PermissionsToSecrets $PermissionsToSecrets -PermissionsToCertificates $PermissionsToCertificates  -PermissionsToStorage $PermissionsToStorage -Overwrite $Overwrite
