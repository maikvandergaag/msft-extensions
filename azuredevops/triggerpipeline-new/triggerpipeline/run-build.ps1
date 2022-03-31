[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)][String]$OrganizationUrl,
    [Parameter(Mandatory = $true)][String]$AzureDevOpsProjectName,
    [Parameter(Mandatory = $false)][String]$DevOpsPAT,
    [Parameter(Mandatory = $false)][Bool]$UseSystemAccessToken,
    [Parameter(Mandatory = $true)][String]$PipelineName,
    [Parameter(Mandatory = $false)][String]$Branch,
    [Parameter(Mandatory = $false)][String]$Description = "Automatically triggered release",
    [Parameter(Mandatory = $false)][String]$BuildApi,
    [Parameter(Mandatory = $false)][String]$Parameters
)

try {
    $parametersObject = ConvertFrom-Json $Parameters
}
catch {
    Write-Error "Supplied json for the variables is not in the correct format!"
}

$ErrorActionPreference = 'Stop';

$id = $PipelineName -as [int]
if($id){
    $getUri = "_apis/build/definitions/$($id)";
}else{
    $getUri = "_apis/build/definitions?name=$(${PipelineName})";
}

#uri
$baseUri = "$($OrganizationUrl)/$($AzureDevOpsProjectName)/";
$runBuild = "_apis/build/builds?api-version=$($BuildApi)"

$buildUri = "$($baseUri)$($getUri)"
$runBuildUri = "$($baseUri)$($runBuild)"

if($UseSystemAccessToken){
    $DevOpsHeaders = @{Authorization = ("Bearer {0}" -f $env:SYSTEM_ACCESSTOKEN)}
}else{
    # enconding PAT
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "", $DevOpsPAT)))
    $DevOpsHeaders = @{Authorization = ("Basic {0}" -f $base64AuthInfo)}
}

$BuildDefinitions = Invoke-RestMethod -Uri $buildUri -Method Get -ContentType "application/json" -Headers $DevOpsHeaders;

if ($BuildDefinitions) {
    if($id){
        $specificUri = $BuildDefinitions.url
    }else{
        $specificUri = $BuildDefinitions.value[0].url
    }

    $Definition = Invoke-RestMethod -Uri $specificUri -Method Get -ContentType "application/json" -Headers $DevOpsHeaders;

    if ($Definition) {
        $Build = New-Object PSObject -Property @{
            definition = New-Object PSObject -Property @{
                id = $Definition.id
            }
            sourceBranch = $Branch
            reason = "userCreated"
            parameters = $Parameters
        }

        $jsonbody = $Build | ConvertTo-Json -Depth 100

        try {
            $Result = Invoke-RestMethod -Uri $runBuildUri -Method Post -ContentType "application/json" -Headers $DevOpsHeaders -Body $jsonbody;
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
