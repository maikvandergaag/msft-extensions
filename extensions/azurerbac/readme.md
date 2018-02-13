Azure Role Based Access Control is a Build and Release Task for Build / Release pipeline.

With this task you can alter role-based access assignments on resource groups. 

Within the task multiple parameters need to be specified:
* Azure Subscription: The subscription to perform the assignments on.
* Resource Group: The Azure resource group name.
* Action: The specific action to perform: Add or Remove.
* Azure Role Assignment: The Role Assignment.
* Users or Group: Perform the action for users or groups.
* Groups: Visible when Groups action is chosen. In this field you need to specify the group names. For multiple separate by (',').
* Users: Visible when Users action is chosen. In this field you need to specify the user principal names of the users. For multiple separate by (','). 
* Fail on Error: Boolean value whether the task should fail when a error occurs.

## Documentation

For the documentation check the [Wiki](https://github.com/MaikvanderGaag/msft-vsts-extensions/wiki).

When you like the extension please leave a review. File a issues when you have suggestions or problems with the extension.

[Issues](https://github.com/MaikvanderGaag/msft-vsts-extensions/issues)
