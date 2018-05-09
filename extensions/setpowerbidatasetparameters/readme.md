Set PowerBI dataset parameters is a Build and Release Task for wihtin your Build / Release pipeline.

With this task you can update parameters of an exisiting PowerBI dataset in specific group within powerbi.com. 

Within the task multiple parameters need to be specified:
* Username: The name of a user that has write access to the dataset.
* Password: The password of the user that has write access to the dataset. This value should be saved as a secured variable.
* ClientId: The ClientId of the application that has access to the PowerBI API.
* TenantId: The PowerBI TenantId where the dataset resides.
* GroupId: The GroupId/WorkspaceId were the dataset resides.
* DatasetId: The DatasetId of the dataset that we want to set the parameters to.
* ParamsArray: The parameters array to set in a json format:
    Example:
    [{"name": "MaxId","newValue": "5678"},{"name": "StrParam","newValue": "Another Hello"}] 

*Refresh: If the dataset should be refreshed following the setting of the parameters, true by default. 

Notes on Parameters:
* Parameters should be defined in the dataset.
* Parameters cannot be of type 'Any' or 'Binary'
for more details see: https://msdn.microsoft.com/en-us/library/mt845781.aspx

In order to make this extension work a application should be created with access to the PowerBI api. Besides that you should have a user that has access to the application your specified in Azure Active Directory.

**Azure Active Directory Application**

![Application](https://github.com/maikvandergaag/msft-vsts-extensions/raw/master/docs/images/application.png "Azure Active Directory Application")

**Permissions**

![Permissions](https://github.com/maikvandergaag/msft-vsts-extensions/raw/master/docs/images/permissions.png "Azure Active Directory Permissions")

## Documentation

For the documentation check the [Wiki](https://github.com/MaikvanderGaag/msft-vsts-extensions/wiki).

When you like the extension please leave a review. File a issues when you have suggestions or problems with the extension.

[Issues](https://github.com/MaikvanderGaag/msft-vsts-extensions/issues)