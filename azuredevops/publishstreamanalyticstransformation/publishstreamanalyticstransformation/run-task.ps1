Trace-VstsEnteringInvocation $MyInvocation

$path = Get-VstsInput -Name FilePath -Require
$jobName = Get-VstsInput -Name StreamAnalyticsJobName -Require
$streamingUnits =  Get-VstsInput -Name StreamingUnit -Require
$transformationName =  Get-VstsInput -Name TransformationName -Require

. "$PSScriptRoot\Utility.ps1"
. "$PSScriptRoot\streamanalytics.ps1"
$targetAzurePs = Get-RollForwardVersion -azurePowerShellVersion $targetAzurePs

$authScheme = ''
try
{
    $serviceNameInput = Get-VstsInput -Name ConnectedServiceNameSelector -Default 'ConnectedServiceName'
    $serviceName = Get-VstsInput -Name $serviceNameInput -Default (Get-VstsInput -Name DeploymentEnvironmentName)
    if (!$serviceName)
    {
            Get-VstsInput -Name $serviceNameInput -Require
    }

    $endpoint = Get-VstsEndpoint -Name $serviceName -Require

    if($endpoint)
    {
        $authScheme = $endpoint.Auth.Scheme 
    }

     Write-Verbose "AuthScheme $authScheme"
}
catch
{
   $error = $_.Exception.Message
   Write-Verbose "Unable to get the authScheme $error" 
}

Update-PSModulePathForHostedAgent -targetAzurePs $targetAzurePs -authScheme $authScheme

try {
    # Initialize Azure.
    Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
    Initialize-Azure -azurePsVersion $targetAzurePs -strict   
	
	$resourceGroup = Get-StreamAnalyticsJobGroupName -resourceName $jobName
	Write-Host "Resource Group of the Stream Analytics Job is: $resourceGroup"

	# Getting the File Content
	Write-Host "Getting the content of the stream analytics query file '$path'."
    $fileString = Get-Content $path

	$fileContent = ""
	For ($i=0; $i -le $fileString.Length; $i++) {
		$fileContent += $fileString[$i]

		if($i + 1 -lt $fileString.Length){
			$fileContent += "\n"
		}
	}
	
	# Saving the transformation file
	$number = Get-Random
	$fileName = "Temp" + $number + ".json"
    $transformation = "{""properties"" : { ""streamingUnits"": $streamingUnits, ""query"": ""$fileContent"" }}"  
	Write-Host $transformation
	$file = New-Item -path $PSScriptRoot\$fileName -Name $file -Value $transformation -ItemType file -force

	Write-Host "Tempory file created, ready to update the transformation: $transformationName!"

	New-AzureRMStreamAnalyticsTransformation -ResourceGroupName $resourceGroup –File $PSScriptRoot\$fileName –JobName $jobName –Name $transformationName -Force
	
	$file = Remove-Item -Path $PSScriptRoot\$fileName
	Write-Host "Tempory file deleted."
}
finally 
{
	  Trace-VstsLeavingInvocation $MyInvocation
}