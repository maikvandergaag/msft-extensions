Power BI Actions is a Build and Release Task for within your Build / Release pipeline in [Azure Devops](https://azure.microsoft.com/en-gb/services/devops/).

With this task you can publish a Power BI file or multiple files to a specific group within [powerbi.com](https://powerbi.microsoft.com/). It also gives you the option to update the DirectQuery datasource connection string.

Within the task multiple parameters need to be specified:
* **Source File:** The location of the PowerBI file can be a search query "*.pbix".
* **Username:** The name of the user that will publish the file.
* **Password:** The password of the user that will publish the file. **This value should be saved as a secured variable.**
* **ClientId:** The ClientId of the application that has access to the PowerBI API.
* **Overwrite:** Checkbox for specifying if the PowerBI report should be overwritten.
* **GroupName:** The groupname were the file should be published to. You can also use your own workspace (me).
* **Create:** Create the group if it does not exist. 
* **Dataset:** The name of the dataset to alter.
* **Connectionstring:** The connection string to update in the dataset.

In order to make this extension work a Power BI application should be created with access to the Power BI API with the required permissions. A How-To guide for registering a Power BI application can be found on the following page. Make sure you register a **Native** application within Azure Active Directory:

[Register an Azure AD app to embed Power BI content](https://docs.microsoft.com/en-us/power-bi/developer/register-app)

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
| 2.0.5   | Added TLS 1.2 support  |
| 3.0.0   | Changed authentication method to a Generic Service Connection |
