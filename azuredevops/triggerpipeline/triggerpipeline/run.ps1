[CmdletBinding()]
param()
Trace-VstsEnteringInvocation $MyInvocation

try {
    # Get VSTS input values
	
	$connectedServiceName = Get-VstsInput -Name ConnectedServiceName
	$serviceEndpoint = Get-VstsEndpoint -Name $connectedServiceName -Require

	#connected service
	$userName =  $serviceEndpoint.Auth.Parameters.username
	$pat = $serviceEndpoint.Auth.Parameters.password

	Write-Host "******************************"
	Write-Host "** Service Connection: $($connectedServiceName)"
	Write-Host "** Username: $($userName)"
	Write-Host "** PAT: $($pat)"
	Write-Host "******************************"

	#parameters
	$AzureDevOpsProjectName = Get-VstsInput -Name AzureDevOpsProjectName -Require
	$PipelineName = Get-VstsInput -Name PipelineName -Require
	$Pipeline = Get-VstsInput -Name Pipeline -Require
	$Description = Get-VstsInput -Name Description
	$Branch= Get-VstsInput -Name Branch
	$BuildNumber = Get-VstsInput -Name BuildNumber

    if ($Pipeline -eq "Build") {
        .\run-build.ps1 -AzureDevOpsAccount $AzureDevOpsAccount -AzureDevOpsProjectName $AzureDevOpsProjectName -Username $Username -DevOpsPAT $pat -PipelineName $PipelineName -Description $Description -Branch $Branch
    }
    elseif ($Pipeline -eq "Release") {
        .\run-release.ps1 -AzureDevOpsAccount $AzureDevOpsAccount -AzureDevOpsProjectName $AzureDevOpsProjectName -Username $Username -DevOpsPAT $pat -PipelineName $PipelineName -Description $Description -BuildNumber $BuildNumber
    }  
}
finally {
    Trace-VstsLeavingInvocation $MyInvocation
}