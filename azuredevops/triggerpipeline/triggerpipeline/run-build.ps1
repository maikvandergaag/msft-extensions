[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)][String]$OrganizationUrl,
    [Parameter(Mandatory = $true)][String]$AzureDevOpsProjectName,
    [Parameter(Mandatory = $true)][String]$Username,
    [Parameter(Mandatory = $true)][String]$DevOpsPAT,
    [Parameter(Mandatory = $true)][String]$PipelineName,
    [Parameter(Mandatory = $true)][String]$Branch,
    [Parameter(Mandatory = $false)][String]$Description = "Automatically triggered release"
)

$ErrorActionPreference = 'Stop';

Write-Output "OrganizationUrl             : $($OrganizationUrl)";
Write-Output "AzureDevOpsProjectName      : $($AzureDevOpsProjectName)";
Write-Output "PipelineName                : $($PipelineName)";
Write-Output "DevOpsPAT                   : $(if (![System.String]::IsNullOrWhiteSpace($DevOpsPAT)) { '***'; } else { '<not present>'; })";
Write-Output "Branch                      : $($Branch)";

#uri
$baseUri = "$($OrganizationUrl)/$($AzureDevOpsProjectName)/";
$getUri = "_apis/build/definitions?name=$(${PipelineName})";
$runBuild = "_apis/build/builds"

$buildUri = "$($baseUri)$($getUri)"
$runBuildUri = "$($baseUri)$($runBuild)"

# Base64-encodes the Personal Access Token (PAT) appropriately
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("token:{1}" -f $DevOpsPAT)))
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

        $Result = Invoke-RestMethod -UseBasicParsing -Uri $runBuildUri -Method Post -ContentType "application/json" -Headers $DevOpsHeaders -Body $jsonbody;

        Write-Host "Triggered Build: $($Result.buildnumber)"
    }
    else {
        Write-Error "The Build definition could not be found."
    }
}
else {
    Write-Error "Problem occured while getting the build"
}