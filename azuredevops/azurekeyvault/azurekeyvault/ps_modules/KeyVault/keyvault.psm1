Function Get-KeyVaultSecret {
    Param(
        [parameter(Mandatory = $true)]$KeyVaultName,
        [parameter(Mandatory = $true)]$SecretName,
        [parameter(Mandatory = $false)]$VariableName
    )

    $result = Get-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -ErrorAction SilentlyContinue -ErrorVariable SecretError;
    If ($SecretError -ne $Null) {
        Write-Error "Secret with name '$($SecretName)' cannot be accessed. Error: $SecretError";
        Write-Host "##vso[task.logissue type=error;] Secret with name '$($SecretName)' cannot be accessed. Error: $SecretError";
        Exit;
    }
    $secretValue = $result.SecretValueText

    if(!$secretValue){
        Write-Warning "There is no secret with the name $($SecretName)"
    }else{
        if($VariableName){
            Set-AzureDevOpsVariable -VariableName $VariableName -VariableValue $secretValue
        }
    }
    return $result
}

Function Remove-KeyVaultSecret {
    Param(
        [parameter(Mandatory = $true)]$KeyVaultName,
        [parameter(Mandatory = $true)]$SecretName
    )

    Get-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -ErrorAction SilentlyContinue -ErrorVariable SecretError;
    If ($SecretError -ne $Null) {
        Write-Error "Secret with name '$($SecretName)' cannot be accessed or does not exist. Error: $SecretError";
        Write-Host "##vso[task.logissue type=error;] Secret with name '$($SecretName)' cannot be accessed. Error: $SecretError";
        Exit;
    }

    Remove-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -Force
}

Function Add-KeyVaultPolicy{
    Param(
        [parameter(Mandatory = $true)]$KeyVaultName,
        [parameter(Mandatory = $true)]$ObjectId,
        [parameter(Mandatory = $true)]$PermissionsToKeys,
        [parameter(Mandatory = $true)]$PermissionsToSecrets,
        [parameter(Mandatory = $true)]$PermissionsToCertificates,
        [parameter(Mandatory = $true)]$PermissionsToStorage
    )

    $keys = $PermissionsToKeys.Split(",",[StringSplitOptions]'RemoveEmptyEntries')
    $secrets = $PermissionsToSecrets.Split(",",[StringSplitOptions]'RemoveEmptyEntries')
    $certificates = $PermissionsToCertificates.Split(",",[StringSplitOptions]'RemoveEmptyEntries')
    $storage = $PermissionsToStorage.Split(",",[StringSplitOptions]'RemoveEmptyEntries')

    $result = Set-AzureRmKeyVaultAccessPolicy -VaultName $KeyVaultName -ObjectId $ObjectId -BypassObjectIdValidation -PermissionsToKeys $keys -PermissionsToSecrets $secrets -PermissionsToCertificates $certificates -PermissionsToStorage $storage

    $result
}

Function Remove-KeyVaultPolicy{
    Param(
        [parameter(Mandatory = $true)]$KeyVaultName,
        [parameter(Mandatory = $true)]$ObjectId
    )

    Remove-AzureRmKeyVaultAccessPolicy -VaultName $KeyVaultName -ObjectId $ObjectId
}

Function Get-KeyVaultCertificateUrl {
    Param(
        [parameter(Mandatory = $true)]$KeyVaultName,
        [parameter(Mandatory = $true)]$CertificateName,
        [parameter(Mandatory = $true)]$VariableName
    )

    $cert = Get-AzureKeyVaultCertificate -VaultName $keyVaultName -CertificateName $CertificateName -ErrorVariable SecretError;
    If ($SecretError -ne $Null) {
        Write-Error "Certificate with name '$($CertificateName)' cannot be accessed. Error: $SecretError";
        Write-Host "##vso[task.logissue type=error;] Secret with name '$($CertificateName)' cannot be accessed. Error: $SecretError";
        Return;
    }

    $certificateUri = $cert.SecretId;

    if(!$certificateUri){
        Write-Warning "There is no certificate with the name $($CertificateName)"
    }else{
        if($VariableName){
            Set-AzureDevOpsVariable -VariableName $VariableName -VariableValue $secretValue
        }
    }
}


Function Import-KeyVaultCertificate{
    Param(
        [parameter(Mandatory = $true)]$KeyVaultName,
        [parameter(Mandatory = $true)]$CertificatePath,
        [parameter(Mandatory = $true)]$CertificateName,
        [parameter(Mandatory = $true)]$CertificatePassword,
        [parameter(Mandatory = $false)]$VariableName,
        [parameter(Mandatory = $false)]$Overwrite
    )

    $Password = ConvertTo-SecureString -String $CertificatePassword -AsPlainText -Force
    $result = Get-AzureKeyVaultCertificate -VaultName $KeyVaultName -CertificateName $CertificateName

    if($result -and $Overwrite){
        $result = Import-AzureKeyVaultCertificate -VaultName $KeyVaultName -Name $CertificateName -FilePath $CertificatePath -Password $Password   
    }else{
        if(!$result){
            $result = Import-AzureKeyVaultCertificate -VaultName $KeyVaultName -Name $CertificateName -FilePath $CertificatePath -Password $Password 
        }else{
            Write-Warning "Certificate with the name: $($CertificateName) already exists"
        }
    }

    if($VariableName){
        Set-AzureDevOpsVariable -VariableName $VariableName -VariableValue $result.SecretId
    }
}

Function Set-KeyVaultSecret {
    Param(
        [parameter(Mandatory = $true)]$KeyVaultName,
        [parameter(Mandatory = $true)]$SecretName,
        [parameter(Mandatory = $true)]$SecretValue,
        [parameter(Mandatory = $false)]$VariableName,
        [parameter(Mandatory = $false)]$Overwrite
    )
    $secretvalue = ConvertTo-SecureString $SecretValue -AsPlainText -Force
    $result = Get-KeyVaultSecret -KeyVaultName $KeyVaultName -SecretName $SecretName

    if($result -and $Overwrite){
        $result = Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -SecretValue $secretvalue       
    }else{
        if(!$result){
            $result = Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -SecretValue $secretvalue       
        }else{
            Write-Warning "Secret with the name: $($SecretName) already exists"
        }
    }

    if($VariableName){
        Set-AzureDevOpsVariable -VariableName $VariableName -VariableValue $result.Id
    }
}

Function Set-AzureDevOpsVariable{
    Param(
        [parameter(Mandatory = $true)]$VariableName,
        [parameter(Mandatory = $true)]$VariableValue
    )

    Write-Host "Value will be saved in the following variable: $($VariableName)";
    Write-Output "##vso[task.setvariable variable=$($VariableName);]$VariableValue"
}

Export-ModuleMember -Function "*-*" 