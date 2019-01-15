[CmdletBinding()]
param()
Trace-VstsEnteringInvocation $MyInvocation

try {
    # Get VSTS input values
	
	$connectedServiceName = Get-VstsInput -Name ConnectedServiceName
	$serviceEndpoint = Get-VstsEndpoint -Name $connectedServiceName -Require

	$json = ConvertTo-Json @serviceEndpoint
	Write-Host $json

	#connected service
	$userName =  $serviceEndpoint.Auth.Parameters.username
	$pat = $serviceEndpoint.Auth.Parameters.password
	$releaseUrl = $serviceEndpoint.Data.releaseUrl
	$organizationUrl = $serviceEndpoint.url

	Write-Host "******************************"
	Write-Host "** Service Connection: $($connectedServiceName)"
	Write-Host "** Release Url: $($releaseUrl)"
	Write-Host "** Organization Url: $($organizationUrl)"
	Write-Host "** PAT: $($pat)"
	Write-Host "******************************"

	#parameters
	$AzureDevOpsProjectName = Get-VstsInput -Name project -Require
	$BuildPipelineName = Get-VstsInput -Name buildDefinition -Require
	$ReleasePipelineName = Get-VstsInput -Name releaseDefinition -Require
	$Description = Get-VstsInput -Name Description
	$Branch= Get-VstsInput -Name Branch
	$BuildNumber = Get-VstsInput -Name BuildNumber

    if ($Pipeline -eq "Build") {
        .\run-build.ps1 -AzureDevOpsAccount $AzureDevOpsAccount -AzureDevOpsProjectName $AzureDevOpsProjectName -Username $Username -DevOpsPAT $pat -PipelineName $BuildPipelineName -Description $Description -Branch $Branch
    }
    elseif ($Pipeline -eq "Release") {
        .\run-release.ps1 -AzureDevOpsAccount $AzureDevOpsAccount -AzureDevOpsProjectName $AzureDevOpsProjectName -Username $Username -DevOpsPAT $pat -PipelineName $ReleasePipelineName -Description $Description -BuildNumber $BuildNumber
    }  
}
finally {
    Trace-VstsLeavingInvocation $MyInvocation
}