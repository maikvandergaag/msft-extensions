Azure Role Based Access Control is a Build and Release Task for wihtin your Build / Release pipeline.

With this tasks you can alter Role Based Access assignments on resource groups. 

Within the task multiple parameters need to be specified:
* Azure Subscription: The subscription to perform the assignments on.
* Resource Group: The Azure resource group name.
* Action: The specific action to take: Add or Remove.
* Azure Role Assignment: The Role Assignment.
* Users or Group: Certain type of action. Action performend for users of groups.
* Groups: Visible when Groups action is chosen. In this field you need to specify the group names. For multiple seperate by (,).
* Users: Visible when Users action is chosen. In this field you need to specify the user principal names of the users. For multiple seperate by (,). 
* Fail on Error: Boolean value wether the task should fail the release when a error occurs.

In order to make this extension work. The application that is registerd in Azure Active Directory by 'Authorizing' the service connection. Should have acces to read directory data.

** Azure Active Directory Applications**
![Application](https://github.com/maikvandergaag/msft-vsts-extensions/raw/master/docs/images/appregistration.png "Azure Active Directory Application")

** Azure Active Directory Application for Service Connection **
![Application](https://github.com/maikvandergaag/msft-vsts-extensions/raw/master/docs/images/vstsapp.png "Azure Active Directory Application")

In order to make this extension work a application should be created with access to the PowerBI api. Besides that you should have a user that has access to the application your specified in Azure Active Directory.

![Permissions](https://github.com/maikvandergaag/msft-vsts-extensions/raw/master/docs/images/permissionsvsts.png "Azure Active Directory Permissions")

## Documentation

For the documentation check the [Wiki](https://github.com/MaikvanderGaag/msft-vsts-extensions/wiki).

When you like the extension please leave a review. File a issues when you have suggestions or problems with the extension.

[Issues](https://github.com/MaikvanderGaag/msft-vsts-extensions/issues)