[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)][String]$OrganizationUrl,
    [Parameter(Mandatory = $true)][String]$ReleaseUrl,
    [Parameter(Mandatory = $true)][String]$AzureDevOpsProjectName,
    [Parameter(Mandatory = $true)][String]$DevOpsPAT,
    [Parameter(Mandatory = $true)][String]$PipelineName,
    [Parameter(Mandatory = $false)][String]$BuildNumber,
    [Parameter(Mandatory = $false)][String]$Stage,
    [Parameter(Mandatory = $false)][String]$Description = "Automatically triggered release"
)

$ErrorActionPreference = 'Stop';

#uri
$baseBuildUri = "$($OrganizationUrl)/$($AzureDevOpsProjectName)/"
$baseReleaseUri = "$($ReleaseUrl)/$($AzureDevOpsProjectName)/";
$getUri = "_apis/release/definitions?searchText=$($PipelineName)&`$expand=environments&isExactNameMatch=true";
$runRelease = "_apis/release/releases?api-version=5.0-preview.8"


$ReleaseUri = "$($baseReleaseUri)$($getUri)"
$RunReleaseUri = "$($baseReleaseUri)$($runRelease)"

# Base64-encodes the Personal Access Token (PAT) appropriately
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("token:{0}" -f $DevOpsPAT)))
$DevOpsHeaders = @{Authorization = ("Basic {0}" -f $base64AuthInfo) };

$ReleaseDefinitions = Invoke-RestMethod -Uri $ReleaseUri -Method Get -ContentType "application/json" -Headers $DevOpsHeaders;
    
if ($ReleaseDefinitions -and $ReleaseDefinitions.count -eq 1) {
    $specificUri = $ReleaseDefinitions.value[0].url
    $Definition = Invoke-RestMethod -Uri $specificUri -Method Get -ContentType "application/json" -Headers $DevOpsHeaders;

    if ($BuildNumber) {
        foreach ($artifact in $Definition.artifacts) {
            if ($artifact.isPrimary) {
                $buildUri = "$($baseBuildUri)_apis/build/builds?definitions=$($artifact.definitionReference.definition.id)&resultfilter=succeeded&buildNumber=$($BuildNumber)&statusFilter=completed&api-version=5.0-preview.5"
                $buildResult = Invoke-RestMethod -Uri $buildUri -Method Get -ContentType "application/json" -Headers $DevOpsHeaders;
            
                if ($buildResult -and $buildResult.count -eq 1) {
                    $artifactsItem = @()
                    $artifactsItem += New-Object PSObject -Property @{
                        alias             = $artifact.Alias
                        instanceReference = New-Object PSObject -Property @{            
                            Id   = $buildResult.value[0].Id
                            Name = $buildResult.value[0].BuildNumber      
                        }
                    }
                }
                else {
                    Write-Error "Could not find specified artifact $($BuildNumber) that has the status succeeded!"
                }            
            }
        }
    }

    if ($Definition) {
        $Release = New-Object PSObject -Property @{            
            definitionId = $Definition.id                 
            isDraft      = $false              
            description  = $Description 
            artifacts    = $artifactsItem           
        }

        $jsonbody = $Release | ConvertTo-Json -Depth 100

        try {
            $Result = Invoke-RestMethod -Uri $RunReleaseUri -Method Post -ContentType "application/json" -Headers $DevOpsHeaders -Body $jsonbody;

            if ($Stage) {
                $releaseId = $Result.id
                $stages = $Stage.Split(",")
                foreach ($env in $stages) {
                    $environment = $Result.environments | Where-Object { $_.Name -eq $env }

                    if ($environment) {
                        $envId = $environment.id
                        $runRelease = "_apis/release/releases/$($releaseId)/environments/$($envId)?api-version=6.1-preview.7"
                        $RunEnvUri = "$($baseReleaseUri)$($runRelease)"

                        $stageBody = New-Object PSObject -Property @{            
                            status                  = "inProgress"
                            scheduledDeploymentTime = $null              
                            comment                 = $null 
                            variables               = $null         
                        }

                        $jsonbody = $stageBody | ConvertTo-Json -Depth 100

                        $Result = Invoke-RestMethod -Uri $RunEnvUri -Method Patch -ContentType "application/json" -Headers $DevOpsHeaders -Body $jsonbody;
                    }
                    else {
                        Write-Error "The specified stage could not be found!"
                    }
                }
            }
        }
        catch {
            if ($_.ErrorDetails.Message) {

                $errorObject = $_.ErrorDetails.Message | ConvertFrom-Json

                foreach ($result in $errorObject.customProperties.ValidationResults) {
                    Write-Warning $result.message
                }
                Write-Error $errorObject.message
            }

            throw $_.Exception 
        }

        Write-Host "Triggered Release: $($Result.name)"
    }
    else {
        Write-Error "The Release definition could not be found."
    }
}
else {
    Write-Error "Problem occured while getting the release"
}
