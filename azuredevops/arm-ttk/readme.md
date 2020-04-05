Azure Resource Manager Template tester is a Build and Release Task for Build / Release pipeline.

It uses the ARM-TTK PowerShell module created by Microsoft to test ARM templates. The Module it self can be found here:

[arm-ttk](https://github.com/Azure/azure-quickstart-templates/tree/master/test/arm-ttk)

Within the task multiple parameters need to be specified:
* Template folder: The folder to check the arm templates
* Stop on violation: Stop pipeline execution on a violation of the rules in the template


## Documentation

For the documentation check the [Wiki](https://github.com/MaikvanderGaag/msft-extensions/wiki).

When you like the extension please leave a review. File a issues when you have suggestions or problems with the extension.

[Issues](https://github.com/MaikvanderGaag/msft-extensions/issues)


## Release Notes

| Version | Remarks                             |  
|---------|-------------------------------------|
| 1.0.0   | Initial version                     |