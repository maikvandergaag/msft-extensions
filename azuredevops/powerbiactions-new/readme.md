Power BI Actions is a Build and Release Task for Azure Pipelines. With this tasks you can automate specific tasks within Power BI.

The following tasks can be automated when using this extension:
* Upload / Import Power BI dashboard (pbix file).
* Create a Power BI workspace.
* Remove a Power BI workspace.
* Add a new Admin user to a Power BI workspace.
* Add a Service Principal to a Power BI workspace.
* Add a Group to a Power BI workspace.
* Update the connection of a Power BI report.
* Refresh a dataset.
* Update SQL Direct Query String

The following organization types are supported from version 5 and higher:

* Commercial (Public)
* Microsoft 365 Government Community Cloud (US)
* Microsoft 365 Government Community Cloud High (US)
* US Department of Defense
* Microsoft Cloud China
* Microsoft Cloud Germany

The task works with a "Power BI" service connection that needs to be configured within the "Service Connections" settings of the project. From version 5 there is one single service connections. In this service connection you can choose between "Username/Password" and "Service Principal" authentication.

### Username/Password

For the service connection to work with a Username password combination you need to configure the following parameters:

* Username: The username of the user that will perform the actions. Make sure the account does not have Multi Factor authentication enabled.
* Password: The password of the user.

**Note**: The user must have a Power BI Pro license in order to perform the tasks.

### Service Principal

To configure a Service Principal with PowerBI you will have to go through this guide:[Service principal with Power BI](https://docs.microsoft.com/en-us/power-bi/developer/embed-service-principal)

* ClientId: The client id of the Azure Active Directory application. This application should have the appropriate rights in order to use the Power BI Api.
* ClientSecret: The client secret of the application
* Tenant ID: The identifier of the Azure Active Directory tenant 

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
| 2.0.0   | Added support for: - Groups that do not exist. - The 'me' workspace. - Updating datasets |
| 3.2.6   | Small bug fix |
| 4.0.0   | Added Service Principal support  |
| 5.1.0   | Added support for Government environments and consolidated |
| 5.2.0   | Added support for PowerBi Report transfer ownership and updating parameters in reports|
