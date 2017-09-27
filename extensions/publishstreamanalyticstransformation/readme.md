Publish Stream Analytics Transformation is a Build and Release Task for wihtin your Build / Release pipeline.

With this tasks you can create a new transformation within a stream analytics job. The tasks uses the default stream analytics powershell module to publish the transformation. 

The tasks extracts the content of a file (for example a *.asaql file) and places this value in the query of the stream analytics job.

Within the task two parameters can be specified:
* Azure Subscription: The Azure Subscription were the Stream Analytics Job is hosted.
* Stream Analytics Job Name: The job name.
* Stream Analytics Query file: The query file within source control.
* Streaming Units: The streaming units of your transformation.
* Transformation Name: The name of the transformation (Default value of the transformation is 'Transformation')

## Documentation

For the documentation check the [Wiki](https://github.com/MaikvanderGaag/msft-vsts-extensions/wiki).

When you like the extension please leave a review. File a issues when you have suggestions or problems with the extension.

[Issues](https://github.com/MaikvanderGaag/msft-vsts-extensions/issues)