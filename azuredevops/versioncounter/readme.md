Version number counter is a Release and Build pipeline tasks that can increment a version number. 

The default version number should be saved as a variable in the release or build pipeline. The task will increment the number based on your configuration.

The following configuration can be made in the task:
* The saved version variable: The name of the variable that contains the version number. This version number should be in the format: *.*.*.
* Automatically update minor number: Checkbox if you want to automatically update the minor version (1.*.0) when the patch version reaches a certain amount.
* Maximum value of the patch number: The maximum number of the patch version number.
* Automatically update major number: Checkbox if you want to automatically update the major version (*.0.0) when the minor version reaches a certain amount.
* Maximum value of the minor number: The maximum number of the minor version number.
* Azure DevOps Personal Access Token: The personal access token that is used for updating the build definition.

The minimal permissions required for the PAT are:
* **Build**: Read & Execute

## Documentation

For the documentation check the [Wiki](https://github.com/MaikvanderGaag/msft-extensions/wiki).

When you like the extension please leave a review. File a issues when you have suggestions or problems with the extension.

[Issues](https://github.com/MaikvanderGaag/msft-extensions/issues)

## Permissions

Make sure the application that is performing the actions has the appropriate rights for settings assignments.

## Release Notes

| Version | Remarks                             |  
|---------|-------------------------------------|
| 1.0.0   | Initial version                     |
| 1.0.5   | Small changes and updated icon      |
| 1.1.4   | Bug fix      |
