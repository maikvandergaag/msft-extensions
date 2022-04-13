Trace-VstsEnteringInvocation $MyInvocation

function Invoke-CustomWebRequest () {
    param(
        [Parameter(Mandatory = $true)][String]$Uri,
        [Parameter(Mandatory = $true)][System.Collections.IDictionary]$Headers,
        [Parameter(Mandatory = $true)][Microsoft.PowerShell.Commands.WebRequestMethod]$Method,
        [Parameter(Mandatory = $false)][String]$ContentType = "application/json",
        [Parameter(Mandatory = $false)][Object]$Body
    )
    try {

        if($Method -eq 'Post' -or $Method -eq 'Put'){
            $response = Invoke-WebRequest -Uri $Uri -ContentType $ContentType -Headers $Headers -Method $Method -Body $Body -UseBasicParsing
        }
        else{
            $response = Invoke-WebRequest -Uri $Uri -ContentType $ContentType -Headers $Headers -Method $Method -UseBasicParsing
        }

        if ($response.StatusCode -lt 300){
           return ConvertFrom-Json $([String]::new($response.Content))
        }
        else {
           Write-Host $response.StatusCode
           Write-Host $response.StatusDescription
        }
     }
     catch {
        Write-Host $_.Exception.Response.StatusDescription
     }
}

$VersionVariable = Get-VstsInput -Name VersionVariable -Require
$UpdateMinorVersion = Get-VstsInput -Name UpdateMinorVersion -Require
$MaxValuePatchVersion = Get-VstsInput -Name MaxValuePatchVersion
$MaxValueMinorVersion = Get-VstsInput -Name MaxValueMinorVersion
$UpdateMajorVersion = Get-VstsInput -Name UpdateMajorVersion
$OnlyUpdateMinor = Get-VstsInput -Name OnlyUpdateMinor -AsBool
$DevOpsPat = Get-VstsInput -Name DevOpsPat
$UseSystemAccessToken = Get-VstsInput -Name UseSystemAccessToken -AsBool
$buildapiversion = Get-VstsInput -Name buildapiversion

$devOpsUri = $env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI
$projectName = $env:SYSTEM_TEAMPROJECT
$projectUriName = $projectName.replace(" ", "%20")
$projectId = $env:SYSTEM_TEAMPROJECTID
$buildId = $env:BUILD_BUILDID
$apiversion = $buildapiversion

Write-Output "VersionVariable      : $($VersionVariable)";
Write-Output "UpdateMinorVersion   : $($UpdateMinorVersion)";
Write-Output "MaxValuePatchVersion : $($MaxValuePatchVersion)";
Write-Output "UpdateMajorVersion   : $($UpdateMajorVersion)";
Write-Output "MaxValueMinorVersion : $($MaxValueMinorVersion)";
Write-Output "DevOpsPAT            : $(if (![System.String]::IsNullOrWhiteSpace($DevOpsPAT)) { '***'; } else { '<not present>'; })"; ;
Write-Output "DevOps Uri           : $($devOpsUri)";
Write-Output "Project Name         : $($projectName)";
Write-Output "Project Id           : $($projectId)";
Write-Output "Only Update Minor    : $($OnlyUpdateMinor)";
Write-Output "API Version          : $($apiversion)";
Write-Output "BuildId              : $($buildId)";

$buildUri = "$($devOpsUri)$($projectUriName)/_apis/build/builds/$($buildId)?api-version=$($apiversion)"

if($UseSystemAccessToken){
    $devOpsHeader = @{Authorization = ("Bearer {0}" -f $env:SYSTEM_ACCESSTOKEN)}
}else{
    # enconding PAT
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "", $DevOpsPAT)))
    $devOpsHeader = @{Authorization = ("Basic {0}" -f $base64AuthInfo)}
}

Write-Host "Invoking rest method 'Get' for the url: $($buildUri)."
$buildDef = Invoke-CustomWebRequest -Uri $buildUri -Method Get -ContentType "application/json" -Headers $devOpsHeader

if ($buildDef) {
    $definitionId = $buildDef.definition.id
    Write-Host "##[debug]Working with definition id: $($definitionId)"
    $defUri = "$($devOpsUri)$($projectUriName)/_apis/build/definitions/$($definitionId)?api-version=$($apiversion)"

    Write-Host "Trying to retrieve the build definition with the url: $($defUri)."
    $definition = Invoke-CustomWebRequest -Method Get -Uri $defUri -Headers $devOpsHeader -ContentType "application/json"

    if ($definition -and $definition.variables.$VersionVariable) {
        Write-Host "Value of the Major Version Variable: $($definition.variables.$VersionVariable.Value)"
        $version = $definition.variables.$VersionVariable.Value

        if (!$version) {
            $version = "1.0.0"
        }

        $items = $version.split('.')

        if ($items.Count -gt 3 -or $items.Count -lt 3) {
            Write-Error "The version number needs to be in the following format '1.0.0'"
        }
        else {
            $patchVersionVar = $items[2]
            $minorVersionVar = $items[1]
            $majorVersionVar = $items[0]

            Write-Host "Current version Major: $($majorVersionVar), Minor $($minorVersionVar), Patch $($patchVersionVar)"

            $minorVersion = [convert]::ToInt32($minorVersionVar, 10)
            $majorVersion = [convert]::ToInt32($majorVersionVar, 10)
            $patchVersion = [convert]::ToInt32($patchVersionVar, 10)

            $updatedMinorVersion = $minorVersion
            $updatedMajorVersion = $majorVersion

            if($OnlyUpdateMinor){
                $updatedPatchVersion = 0
                $updatedMinorVersion = $updatedMinorVersion + 1
			}else{
                $updatedPatchVersion = $patchVersion + 1
			}

            if($UpdateMinorVersion -eq $true){
                if (($MaxValuePatchVersion -ne 0) -and ($updatedPatchVersion -gt $MaxValuePatchVersion)) {
                    Write-Host "Automatically updating minor version number: $($updatedMinorVersion)"
                    $updatedPatchVersion = 0
                    $updatedMinorVersion = $updatedMinorVersion + 1

                }
            }

            if($UpdateMajorVersion -eq $true){
                if (($MaxValueMinorVersion -ne 0) -and ($updatedMinorVersion -gt $MaxValueMinorVersion)) {
                    Write-Host "Automatically updating major version numer: $($updatedMajorVersion)"
                    $updatedMinorVersion = 0
                    $updatedMajorVersion = $majorVersion + 1
                }
            }

            Write-Host "Updating patch version number from: $($patchVersion) to $($updatedPatchVersion)."
            Write-Host "Updating minor version number from: $($minorVersion) to $($updatedMinorVersion)."
            Write-Host "Updating major version number from: $($majorVersion) to $($updatedMajorVersion)."
            $definition.variables.$VersionVariable.Value = "$($updatedMajorVersion).$($updatedMinorVersion).$($updatedPatchVersion)"

            $definitionJson = $definition | ConvertTo-Json -Depth 50 -Compress

            Write-Verbose "Updating Project Build number with URL: $($defUri)"
            Invoke-CustomWebRequest -Method Put -Uri $defUri -Headers $devOpsHeader -ContentType "application/json" -Body ([System.Text.Encoding]::UTF8.GetBytes($definitionJson)) | Out-Null
        }
    }
    else {
        Write-Error "The variables can not be found on the definition: $($MajorVersionVariable), $($MinorVersionVariable), $($PatchVersionVariable)"
    }
}
else {
    Write-Error "Unable to find a build definition for Project $($ProjectName) with the build id: $($buildId)."
}
