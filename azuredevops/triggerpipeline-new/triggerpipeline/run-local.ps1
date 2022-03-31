[CmdletBinding()]
param()

try {
    $OrganizationUrl = "https://dev.azure.com/msftplayground-demo"
    $releaseUrl = "https://vsrm.dev.azure.com/msftplayground-demo"
    $AzureDevOpsProjectName = "Azure DevOps Extension Demo"
    $token = ""
    $BuildPipelineName = "Trigger with Variable"
    $ReleasePipelineName = "Trigger with Variable"
    $Pipeline = "Release"
    $Description = "Test"
    $Branch = ""
    $BuildNumber = ""
    $Variables = "{'Test': 'Test', 'Test1': 'Test1'}"

    if ($Pipeline -eq "Build") {
        .\run-build.ps1 -OrganizationUrl $organizationUrl -AzureDevOpsProjectName $AzureDevOpsProjectName -DevOpsPAT $token -PipelineName $BuildPipelineName -Description $Description -Branch $Branch -BuildApi "6.0"  -Parameters $Variables
    }
    elseif ($Pipeline -eq "Release") {
        .\run-release.ps1 -OrganizationUrl $organizationUrl -ReleaseUrl $releaseUrl -AzureDevOpsProjectName $AzureDevOpsProjectName -DevOpsPAT $token -PipelineName $ReleasePipelineName -Description $Description -BuildNumber $BuildNumber -ReleaseApi "6.0" -Variables $Variables
    }
}
finally {
    Write-Information "Done running the task"
}
