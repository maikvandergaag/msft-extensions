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
	$buildapiversion = Get-VstsInput -Name buildapiversion
	$releaseapiversion = Get-VstsInput -Name releaseapiversion
	$variableInput = Get-VstsInput -Name VariableInput

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
	Write-Host "** Build Api Version: $($buildapiversion)"
	Write-Host "** Release Api Version: $($releaseapiversion)"
	Write-Host "******************************"

	try {
		# Force powershell to use TLS 1.2 for all communications.
		[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls11 -bor [System.Net.SecurityProtocolType]::Tls10;
	}
	catch {
		Write-Warning $error
	}

	if ($Pipeline -eq "Build") {
		.\run-build.ps1 -OrganizationUrl $organizationUrl -AzureDevOpsProjectName $AzureDevOpsProjectName -UseSystemAccessToken $false -DevOpsPAT $token -PipelineName $BuildPipelineName -Description $Description -Branch $Branch -BuildApi $buildapiversion -Parameters $variableInput
	}
	elseif ($Pipeline -eq "Release") {
		.\run-release.ps1 -OrganizationUrl $organizationUrl -ReleaseUrl $releaseUrl -UseSystemAccessToken $false -AzureDevOpsProjectName $AzureDevOpsProjectName -DevOpsPAT $token -PipelineName $ReleasePipelineName -Description $Description -BuildNumber $BuildNumber -Stage $Stages -BuildApi $buildapiversion -ReleaseApi $releaseapiversion -Variables $variableInput
	}
}
finally {
	Trace-VstsLeavingInvocation $MyInvocation
}