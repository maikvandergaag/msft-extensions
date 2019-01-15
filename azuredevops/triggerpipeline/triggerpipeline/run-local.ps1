[CmdletBinding()]
param()

try { 
    $OrganizationUrl = "https://dev.azure.com/msftplayground-demo"
    $releaseUrl = "https://vsrm.dev.azure.com/msftplayground-demo"
    $AzureDevOpsProjectName = "demo"
    $token = "vdmjxzxdett3tlftk2hbvx3s5ty6j4iyymlfzdiz33o577u7vr4a"
    $BuildPipelineName = "demo-CI"
    $ReleasePipelineName = "trigger-release"
    $Pipeline = "Build"
    $Description = "Test"
    $Branch = ""
    $BuildNumber = ""

    if ($Pipeline -eq "Build") {
        .\run-build.ps1 -OrganizationUrl $organizationUrl -AzureDevOpsProjectName $AzureDevOpsProjectName -DevOpsPAT $token -PipelineName $BuildPipelineName -Description $Description -Branch $Branch
    }
    elseif ($Pipeline -eq "Release") {
        .\run-release.ps1 -OrganizationUrl $organizationUrl -ReleaseUrl $releaseUrl -AzureDevOpsProjectName $AzureDevOpsProjectName -DevOpsPAT $token -PipelineName $ReleasePipelineName -Description $Description -BuildNumber $BuildNumber
    }  
}
finally {
    Write-Information "Done running the task"
}
