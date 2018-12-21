Power BI Actions is a Build and Release Task for Azure Pipelines. With this tasks a couple of actions can be performed against PowerBI.com

Actions that can be performed with this extension are:
* Upload Power BI dashboard (pbix file).
* Create a Power BI workspace.
* Remove a Power BI workspace.
* Add a new Admin user to a Power BI workspace.
* Update the connection of a Power BI report.
* Refresh a dataset.

The task works with a "Power BI" service connection that needs to be configured within the "Service Connections" settings of the project.

![Power BI Service Connection][serviceconnection]

For the service connection to work as it should you need to configure the following parameters:

* ClientId: The client id of the native Azure Active Directory application. This application should have the appropriate rights in order to use the Power BI Api. To register an application, check the following URL: [Register an Azure AD app to embed Power BI content](https://docs.microsoft.com/en-us/power-bi/developer/register-app)
* Username: The username of the user that will perform the actions. Make sure the account does not have Multi Factor authentication enabled.
* Password: The password of the user.

Depending on the action you choose within the task you need to supply the following parameters:
* Power BI service connection: The service connection that you have configured.
* Action: The actions that should be performed
* Workspace name: The name of the Power BI workspace
* Source File: The location of the Power BI file that needs to be published. The parameter can also be a search query "*.pbix".
* Overwrite: Checkbox for specifying if the Power BI report should be overwritten.
* Create: Create the Power BI workspace if it does not exist. 
* Dataset: The name of the dataset.
* Users: The users that should be added as Admin to the workspace (separated by ',')
* Datasource type: The datasource type that needs to be changed within the dataset.
* Old Server: The server value that is specified in the existing connection.
* New Server: The server value for the new connection.
* Old Database: The database value that is specified in the existing connection.
* New Database: The database value for the new connection.
* Old Url: The URL value that is specified in the existing connection.
* New Url: The URL value for the new connection.

## Documentation

For the documentation check the [wiki](https://github.com/MaikvanderGaag/msft-extensions/wiki).

If you like the extension, please leave a review. File an issue when you have suggestions or if you experience problems with the extension.

[Issues](https://github.com/MaikvanderGaag/msft-extensions/issues)

## Release Notes

| Version | Remarks                             |  
|---------|-------------------------------------|
| 1.0.0   | Initial version                     |
| 1.2.0   | Fixed issues and some minor changes |
| 2.0.0   | Added support for: - Groups that do not exist. - The 'me' workspace. - Updating datasets |
| 2.0.2   | Updated tags |
| 2.0.3   | Updated file reference |
| 2.0.4   | Integration into CI & CD |
| 2.0.5   | Added TLS 1.2 support |
| 3.0.8   | Added several new actions and updated the authentication to a Service Connection|
| 3.1.0   | Updated Service Connection (ClientId required)|



[serviceconnection]: https://github.com/maikvandergaag/msft-extensions/raw/master/docs/images/serviceconnection.png "Power BI Service Connection"