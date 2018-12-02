This extension is a updated version of the Publish PowerBI files extension.

PowerBI Actions is a Build and Release Task for within your Build / Release pipeline.

With this tasks you can publish a PowerBI file or multiple files to a specific group within powerbi.com. Besides that it also gives you the option to update a connectionstring of a datasource with DirectQuery.

Within the task multiple parameters need to be specified:
* Source File: The location of the PowerBI file can be a search query "*.pbix".
* Username: The name of the user that will publish the file.
* Password: The password of the user that will publish the file. This value should be saved as a secured variable.
* ClientId: The ClientId of the application that has access to the PowerBI API.
* Overwrite: Checkbox for specifying if the PowerBI report should be overwritten.
* GroupName: The groupname were the file should be published to. You can also use your own workspace (me).
* Create: Create the group if it does not exist. 
* Dataset: The name of the dataset to alter.
* Connectionstring: The connection string to update in the dataset.

In order to make this extension work, an application should be created with access to the PowerBI api. Besides that you should have a user that has access to the application you specified in Azure Active Directory.

**Azure Active Directory Application**

![Application](https://github.com/maikvandergaag/msft-extensions/raw/master/docs/images/application.png "Azure Active Directory Application")

**Permissions**

![Permissions](https://github.com/maikvandergaag/msft-extensions/raw/master/docs/images/permissions.png "Azure Active Directory Permissions")

## Documentation

For the documentation check the [Wiki](https://github.com/MaikvanderGaag/msft-extensions/wiki).

If you like the extension please leave a review. File an issue when you have suggestions or if you experience problems with the extension.

[Issues](https://github.com/MaikvanderGaag/msft-extensions/issues)

## Release Notes

| Version | Remarks                             |  
|---------|-------------------------------------|
| 1.0.0   | Initial version                     |
| 1.2.0   | Fixed issues and some minor changes |
| 2.0.0   | Added support for: - Groups that do not exists. - The 'me' workspace. - Updating datasets |
| 2.0.2   | Updated tags |
| 2.0.3   | Updated file reference |
| 2.0.4   | Integration into CI & CD |
| 2.0.5   | Added TLS 1.2 support |
