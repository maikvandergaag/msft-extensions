Trigger Azure DevOps Pipeline is an extension for triggering a Azure DevOps Build or Release Pipeline.

Depending on your choice in the task, it will trigger a build or a release pipeline.

To use the extension, an Azure DevOps API endpoint needs to be created. The token used in the endpoint should be Personal Access Token. How you can create a personal access token can be found here:

* [Use personal access tokens to authenticate](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=vsts)


Make sure the personal access token has the following rights:
* Triggering a Release: Release – Read, write & execute – Build Read & Execute
* Triggering a Build: Read & Execute

For the service connection to work as it should, you need to configure the following parameters:

* Organization Url: The URL of the organization. (https://dev.azure.com/[organization])
* Release API Url: The URL of the Azure DevOps Release API (https://vsrm.dev.azure.com/[organization])
* Personal Access Token: The personal access token.

![Azure DevOps API Service Connection][serviceconnection]

The extension itself has the following parameters

* Azure DevOps service connection: The service connection that you have configured.
* Project: The project where the pipeline resides.
* Pipeline type: The type of pipeline (build / release).
* Release Definition: The definition to trigger.
* Release description: Description for the release. It can also be empty.
* Build Number: If you want to use a specific build number. It will set the build number for the primary artifact. When left empty it will take the latest build.
* Build Definition: The build definition to trigger.
* Branch: The name of the branch to trigger. When left empty, it will use the default configured branch.
* API version: The version of the API to use.
* Variable: JSON string representing the variables to set

## Documentation

For the documentation, check the [wiki](https://github.com/MaikvanderGaag/msft-extensions/wiki).

If you like the extension, please leave a review. File an issue when you have suggestions or if you experience problems with the extension.

[Issues](https://github.com/MaikvanderGaag/msft-extensions/issues)

## Release Notes

| Version | Remarks                             |
|---------|-------------------------------------|
| 1.0.1   | Initial version                     |
| 1.0.3   | Updated documentation               |
| 2.0.3   | Added variable support              |
| 2.0.4   | Breaking change task now refers to Id and not name    |

