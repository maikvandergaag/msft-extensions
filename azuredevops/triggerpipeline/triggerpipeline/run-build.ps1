[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)][String]$OrganizationUrl,
    [Parameter(Mandatory = $true)][String]$AzureDevOpsProjectName,
    [Parameter(Mandatory = $true)][String]$DevOpsPAT,
    [Parameter(Mandatory = $true)][String]$PipelineName,
    [Parameter(Mandatory = $false)][String]$Branch,
    [Parameter(Mandatory = $false)][String]$Description = "Automatically triggered release"
)

$ErrorActionPreference = 'Stop';

#uri
$baseUri = "$($OrganizationUrl)/$($AzureDevOpsProjectName)/";
$getUri = "_apis/build/definitions?name=$(${PipelineName})";
$runBuild = "_apis/build/builds?api-version=5.0-preview.5"

$buildUri = "$($baseUri)$($getUri)"
$runBuildUri = "$($baseUri)$($runBuild)"

# Base64-encodes the Personal Access Token (PAT) appropriately
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("token:{0}" -f $DevOpsPAT)))
$DevOpsHeaders = @{Authorization = ("Basic {0}" -f $base64AuthInfo)};

$BuildDefinitions = Invoke-RestMethod -UseBasicParsing -Uri $buildUri -Method Get -ContentType "application/json" -Headers $DevOpsHeaders;
    
if ($BuildDefinitions -and $BuildDefinitions.count -eq 1) {
    $specificUri = $BuildDefinitions.value[0].url
    $Definition = Invoke-RestMethod -UseBasicParsing -Uri $specificUri -Method Get -ContentType "application/json" -Headers $DevOpsHeaders;

    if ($Definition) {
        $Build = New-Object PSObject -Property @{            
            definition = New-Object PSObject -Property @{            
                id = $Definition.id                           
            }
            sourceBranch = $Branch
            reason = "userCreated"              
        }

        $jsonbody = $Build | ConvertTo-Json -Depth 100

        try {
            $Result = Invoke-RestMethod -UseBasicParsing -Uri $runBuildUri -Method Post -ContentType "application/json" -Headers $DevOpsHeaders -Body $jsonbody;
        } catch {
            if($_.ErrorDetails.Message){

                $errorObject = $_.ErrorDetails.Message | ConvertFrom-Json

                foreach($result in $errorObject.customProperties.ValidationResults){
                    Write-Warning $result.message
                }
                Write-Error $errorObject.message
            }

            throw $_.Exception
        }

        Write-Host "Triggered Build: $($Result.buildnumber)"
    }
    else {
        Write-Error "The Build definition could not be found."
    }
}
else {
    Write-Error "Problem occured while getting the build"
}