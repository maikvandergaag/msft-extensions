The extension is a pipeline task that increments a version number automatically.

The current version number needs to be saved as a variable in the pipeline. During the execution of the task, the number will be incremented based on the configuration.

The following configuration can be made in the task:
* The saved version variable: The variable's name containing the version. This version should be in the format: *.*.*. (for example 1.0.1)
* Automatically update minor number: Checkbox if you want to automatically update the minor version (1.*.0) when the patch version reaches a certain amount.
* Maximum value of the patch number: The maximum number of the patch version number.
* Automatically update significant number: Checkbox if you want to automatically update the major version (*.0.0) when the minor version reaches a certain amount.
* Maximum value of the minor number: The maximum number of the small version number.
* Use system OAuth token: Use the system OAuth token for authentication. When not checked, it will fall back to a personal access token.
* Azure DevOps Personal Access Token: The personal access token used to update the build definition.


## Permissions

### OAuth
When using the OAuth system token. The build identity: Project Collection Build Service ({OrgName}) should have the "Edit build pipeline" permissions.

### Personal Access Token

The minimal permissions required for the PAT are:
* **Build**: Read & Execute

## Documentation
For the documentation, check the [Wiki](https://github.com/MaikvanderGaag/msft-extensions/wiki).

If you like the extension, please leave a review. File issues when you have suggestions or problems with the extension.
[Issues](https://github.com/MaikvanderGaag/msft-extensions/issues)


## Release Notes

| Version | Remarks                             |
|---------|-------------------------------------|
| 1.0.0   | Initial version                     |
| 1.0.5   | Small changes and updated icon      |
| 1.1.4   | Bug fix      |
| 2.0.4   | Added OAuth options and fixed URL problems   |
