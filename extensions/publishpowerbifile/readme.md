# This extension is discontinued
In order to get the same functionality with extra actions get the extension **PowerBI Actions**

* https://marketplace.visualstudio.com/items?itemName=maikvandergaag.maikvandergaag-power-bi-actions

Publish PowerBI file is a Build and Release Task for wihtin your Build / Release pipeline.

With this tasks you can publish a PowerBI file or multiple files to a specific group within powerbi.com. 

Within the task multiple parameters need to be specified:
* Source File: The location of the PowerBI file can be a search query "*.pbix".
* Username: The name of the user that will publish the file.
* Password: The password of the user that will publish the file. This value should be saved as a secured variable.
* ClientId: The ClientId of the application that has access to the PowerBI API.
* Overwrite: Checkbox for specifying if the PowerBI report should be overwritten.
* GroupName: The groupname were the file should be published to. 

In order to make this extension work a application should be created with access to the PowerBI api. Besides that you should have a user that has access to the application your specified in Azure Active Directory.

**Azure Active Directory Application**

![Application](https://github.com/maikvandergaag/msft-vsts-extensions/raw/master/docs/images/application.png "Azure Active Directory Application")

**Permissions**

![Permissions](https://github.com/maikvandergaag/msft-vsts-extensions/raw/master/docs/images/permissions.png "Azure Active Directory Permissions")

## Documentation

For the documentation check the [Wiki](https://github.com/MaikvanderGaag/msft-vsts-extensions/wiki).

When you like the extension please leave a review. File a issues when you have suggestions or problems with the extension.

[Issues](https://github.com/MaikvanderGaag/msft-vsts-extensions/issues)

## Release Notes

| Version | Remarks                             |  
|---------|-------------------------------------|
| 1.0.0   | Initial version                     |
| 1.2.0   | Fixed issues and some minor changes |
| 1.2.3   | Extension discontinued use extension "PowerBI Actions" instead https://marketplace.visualstudio.com/items?itemName=maikvandergaag.maikvandergaag-power-bi-actions | 