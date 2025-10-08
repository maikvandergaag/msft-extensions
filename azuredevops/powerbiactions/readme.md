BI Reporting Actions is a Build and Release Task for Azure Pipelines. With this tasks a couple of actions can be performed against PowerBI.com

Actions that can be performed with this extension are:
* Upload Power BI dashboard (pbix file).
* Create a Power BI workspace.
* Remove a Power BI workspace.
* Add a new Admin user to a Power BI workspace.
* Add a Service Principal to a Power BI workspace.
* Add a Group to a Power BI workspace.
* Update the connection of a Power BI report.
* Refresh a dataset.
* Update SQL Direct Query String

The task works with a "Power BI" service connection that needs to be configured within the "Service Connections" settings of the project. Within the latest version there are two types of service connections one for a connection with a Service Principal and one with a user:

### User

For the service connection to work as it should you need to configure the following parameters:

* ClientId: The client id of the native Azure Active Directory application. This application should have the appropriate rights in order to use the Power BI Api. To register an application, check the following URL: [Register an Azure AD app to embed Power BI content](https://docs.microsoft.com/en-us/power-bi/developer/register-app)
* Username: The username of the user that will perform the actions. Make sure the account does not have Multi Factor authentication enabled.
* Password: The password of the user.

**Note**: The user must have a Power BI Pro license in order to perform the tasks.

### Service Principal

To configure a Service Principal with PowerBI you will have to go through this guide:[Service principal with Power BI](https://docs.microsoft.com/en-us/power-bi/developer/embed-service-principal)

* ClientId: The client id of the Azure Active Directory application. This application should have the appropriate rights in order to use the Power BI Api.
* ClientSecret: The client secret of the application
* Tenant ID: The identifier of the Azure Active Directory tenant 

Depending on the action you choose within the task you need to supply the following parameters:
* Power BI service connection: The service connection that you have configured.
* Action: The actions that should be performed
* Workspace name: The name of the Power BI workspace
* Source File: The location of the Power BI file that needs to be published. The parameter can also be a search query "*.pbix".
* Overwrite: Checkbox for specifying if the Power BI report should be overwritten.
* Create: Create the Power BI workspace if it does not exist. 
* UpdateAll: Will update all datasets if checked.
* Dataset: The name of the dataset.
* Users: The users that should be added to the workspace (separated by ',')
* Service Principals: The users that should be added to the workspace (separated by ',')
* Groups : The group object Id that should be added to the workspace (separated by ',')
* Datasource type: The datasource type that needs to be changed within the dataset.
* Old Server: The server value that is specified in the existing connection.
* New Server: The server value for the new connection.
* Old Database: The database value that is specified in the existing connection.
* New Database: The database value for the new connection.
* Old Url: The URL value that is specified in the existing connection.
* New Url: The URL value for the new connection.

## Output

During the execution of the task different values will be placed inside variables:

* PowerBIActions.ReportId: The report Id of the uploaded report (only supported when uploading one report).
* PowerBIActions.WorkspaceId: The Id of the workspace.

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
| 3.2.4   | Added feature to update all datasets at once|
| 3.2.6   | Small bug fix |
| 4.0.0   | Added Service Principal support  |
| 4.1.16  | Added possibility to add a security group to a workspace, output variables |
| 4.1.17  | Fixed bug naming |
