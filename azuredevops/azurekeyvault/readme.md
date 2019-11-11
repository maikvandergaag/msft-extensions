Azure Key Vault Actions is a Build and Release Task for Build / Release pipeline.

Actions that can be carried out with this extension are:
* Get Azure Key Vault secret value
* Add / Update Azure Key Vault secret
* Remove Azure Key Vault secret
* Add access policy
* Remove access policy
* Import Azure Key Vault certificate
* Get Azure Key Vault certificate Uri

## Information

This extension solves a problem for maintaining and deploying large environments with Azure DevOps. An example for such an environment is when you are deploying Azure App Services with a managed identity. This Identity may need access to the Key Vault to retrieve secrets or when you would like to re-deploy a completely new environment with all the configuration.

In Azure DevOps there is a default integration with the Azure Key Vault. I found that this integration does not offer all the actions that you may want to carry out that’s why the extension was created.

## Prerequisites

To be able to use the extension you need an existing Key Vault. The service connection that you will be using should have access to this Key Vault.

## Parameters

Within the task multiple parameters need to be specified:
* Azure RM Subscription: The subscription / service connection to connect to.
* Action: The specific action to perform on the specified Key Vault.
* Key Vault name: The name of the key vault.
* Secret name: The name for the secret.
* Secret: The secret value, for this value you should use a secured variable within Azure DevOps Pipelines.
* Certificate name: Name of the certificate to retrieve or import. 
* Certificate file: The certificate file to import.
* Certificate password: The password of the certificate.
* ObjectId: The objectId of the object in Azure Active Directory to give access to or remove from the access policies.
* Permissions to keys: Permissions to the keys separated by ','
* Permissions to secrets: Permissions to the secrets separated by ','
* Permissions to certificates: Permissions to the certificates separated by ','
* Permissions to storage: Permissions to the storage separated by ','
* Variable name: The name of the variable to save the results to.
* Overwrite: Overwrite the secret or certificate if it already present is in the Key Vault.

## Documentation

For the documentation check the [Wiki](https://github.com/MaikvanderGaag/msft-extensions/wiki).

When you like the extension please leave a review. File an issue when you have suggestions or problems with the extension.

[Issues](https://github.com/MaikvanderGaag/msft-extensions/issues)

## Permissions

Make sure the application that is performing the actions has the appropriate rights for settings assignments.

## Release Notes

| Version | Remarks                             |  
|---------|-------------------------------------|
| 1.0.0   | Initial version                     |
| 2.0.0   | Changed name in task for yaml users |


