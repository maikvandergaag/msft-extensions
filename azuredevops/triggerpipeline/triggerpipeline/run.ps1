[CmdletBinding()]
param()
Trace-VstsEnteringInvocation $MyInvocation

try {
	# Get VSTS input values
	
	$connectedServiceName = Get-VstsInput -Name ConnectedServiceName
	$serviceEndpoint = Get-VstsEndpoint -Name $connectedServiceName -Require

	#connected service
	$userName = $serviceEndpoint.Auth.Parameters.username
	$token = $serviceEndpoint.Auth.Parameters.apitoken
	$releaseUrl = $serviceEndpoint.Data.releaseUrl
	$organizationUrl = $serviceEndpoint.url

	#parameters
	$AzureDevOpsProjectName = Get-VstsInput -Name project -Require
	$BuildPipelineName = Get-VstsInput -Name buildDefinition
	$ReleasePipelineName = Get-VstsInput -Name releaseDefinition
	$Pipeline = Get-VstsInput -Name Pipeline
	$Description = Get-VstsInput -Name Description
	$Branch = Get-VstsInput -Name Branch
	$BuildNumber = Get-VstsInput -Name BuildNumber
	$Stages = Get-VstsInput -Name Stages

	Write-Host "******************************"
	Write-Host "** Service Connection: $($connectedServiceName)"
	Write-Host "** Release Url: $($releaseUrl)"
	Write-Host "** Organization Url: $($organizationUrl)"
	Write-Host "** Token: $($token)"
	Write-Host "** Project name: $($AzureDevOpsProjectName)"
	Write-Host "** Pipeline: $($Pipeline)"
	Write-Host "** Build pipeline: $($BuildPipelineName)"
	Write-Host "** Release pipeline: $($ReleasePipelineName)"
	Write-Host "** Description: $($Description)"
	Write-Host "** Branch: $($Branch)"
	Write-Host "** BuildNumber: $($BuildNumber)"
	Write-Host "** Stages: $($Stages)"
	Write-Host "******************************"

	if ($Pipeline -eq "Build") {
		.\run-build.ps1 -OrganizationUrl $organizationUrl -AzureDevOpsProjectName $AzureDevOpsProjectName -DevOpsPAT $token -PipelineName $BuildPipelineName -Description $Description -Branch $Branch
	}
	elseif ($Pipeline -eq "Release") {
		.\run-release.ps1 -OrganizationUrl $organizationUrl -ReleaseUrl $releaseUrl -AzureDevOpsProjectName $AzureDevOpsProjectName -DevOpsPAT $token -PipelineName $ReleasePipelineName -Description $Description -BuildNumber $BuildNumber -Stage $Stages
	}  
}
finally {
	Trace-VstsLeavingInvocation $MyInvocation
}