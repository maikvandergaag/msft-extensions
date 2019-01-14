[CmdletBinding()]
param()

try { 
    $AzureDevOpsAccount = "msftplayground"
    $AzureDevOpsProjectName = "msft-demo"
    $Username = "maik@familie-vandergaag.nl"
    $DevOpsPAT = "tc33z72p5s36iffhgllfbd4vml6wcwjtt7b3grsl2x47ckdu5adq"
    $PipelineName = "partsunlimited - private"
    $Pipeline = "Release"
    $Description = "Test"
    $Branch = "develop"
    $BuildNumber = ""

    if ($Pipeline -eq "Build") {
        .\run-build.ps1 -AzureDevOpsAccount $AzureDevOpsAccount -AzureDevOpsProjectName $AzureDevOpsProjectName -Username $Username -DevOpsPAT $DevOpsPAT -PipelineName $PipelineName -Description $Description -Branch $Branch
    }
    elseif ($Pipeline -eq "Release") {
        .\run-release.ps1 -AzureDevOpsAccount $AzureDevOpsAccount -AzureDevOpsProjectName $AzureDevOpsProjectName -Username $Username -DevOpsPAT $DevOpsPAT -PipelineName $PipelineName -Description $Description -BuildNumber $BuildNumber
    }  
}
finally {
    Write-Information "Done running the task"
}
