Trace-VstsEnteringInvocation $MyInvocation

$VersionVariable = Get-VstsInput -Name VersionVariable -Require
$UpdateMinorVersion = Get-VstsInput -Name UpdateMinorVersion -Require
$MaxValuePatchVersion = Get-VstsInput -Name MaxValuePatchVersion -Require
$MaxValueMinorVersion = Get-VstsInput -Name MaxValueMinorVersion -Require
$UpdateMinorVersion = Get-VstsInput -Name UpdateMajorVersion -Require
$DevOpsPat = Get-VstsInput -Name DevOpsPat -Require

$devOpsUri = $env:SYSTEM_TEAMFOUNDATIONSERVERURI
$projectName = $env:SYSTEM_TEAMPROJECT
$projectId = $env:SYSTEM_TEAMPROJECTID 
$buildId = $env:BUILD_BUILDID

Write-Output "VersionVariable                : $($VersionVariable)";
Write-Output "UpdateMinorVersion             : $($UpdateMinorVersion)";
Write-Output "MaxValuePatchVersion           : $($MaxValuePatchVersion)";
Write-Output "UpdateMajorVersion             : $($UpdateMajorVersion)";
Write-Output "MaxValueMinorVersion           : $($MaxValueMinorVersion)";
Write-Output "DevOpsPAT                  	 : $(if (![System.String]::IsNullOrWhiteSpace($DevOpsPAT)) { '***'; } else { '<not present>'; })"; ;
Write-Output "DevOps Uri           		     : $($devOpsUri)";
Write-Output "Project Name          	     : $($projectName)";
Write-Output "Project Id           			 : $($projectId)";
Write-Output "BuildId            		     : $($buildId)";

$buildUri = "$($devOpsUri)$($projectName)/_apis/build/builds/$($buildId)?api-version=4.1"

# enconding PAT
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "", $DevOpsPAT)))
$devOpsHeader = @{Authorization = ("Basic {0}" -f $base64AuthInfo)}

Write-Host "Invoking rest method 'Get' for the url: $($buildUri)."
$buildDef = Invoke-RestMethod -Uri $buildUri -Method Get -ContentType "application/json" -Headers $devOpsHeader

if ($buildDef) {
    $definitionId = $buildDef.definition.id
    $defUri = "$($devOpsUri)$($projectName)/_apis/build/definitions/$($definitionId)?api-version=4.1"

    Write-Host "Trying to retrieve the build definition with the url: $($defUri)."
    $definition = Invoke-RestMethod -Method Get -Uri $defUri -Headers $devOpsHeader -ContentType "application/json"

    if ($definition.variables.$VersionVariable) {
        Write-Host "Value of the Major Version Variable: $($definition.variables.$VersionVariable.Value)"
        $version = $definition.variables.$VersionVariable.Value

        if(!$version){
            $version = "1.0.0"
        }

        $items = $version.split('.')

        Write-Host "Value of the Major Version Variable: $($definition.variables.$MajorVersionVariable.Value)"
        Write-Host "Value of the Minor Version Variable: $($definition.variables.$MinorVersionVariable.Value)"
        Write-Host "Value of the Patch Version Variable: $($definition.variables.$PatchVersionVariable.Value)"

		$minorVersion = [convert]::ToInt32($definition.variables.$MinorVersionVariable.Value, 10)
		$majorVersion = [convert]::ToInt32($definition.variables.$MajorVersionVariable.Value, 10)
		$patchVersion = [convert]::ToInt32($definition.variables.$PatchVersionVariable.Value, 10)
		
		$updatedPatchVersion = $patchVersion + 1
        $updatedMinorVersion = $minorVersion
        $updatedMajorVersion = $majorVersion

		if(($MaxValuePatchVersion -ne 0) -and ($updatedPatchVersion -gt $MaxValuePatchVersion) -and $UpdateMinorVersion){
			$updatedPatchVersion = 0
			$updatedMinorVersion = $updatedMinorVersion + 1
        }
        
        if(($MaxValueMinorVersion -ne 0) -and ($updatedMinorVersion -gt $MaxValueMinorVersion) -and $UpdateMajorVersion){
			$updatedMinorVersion = 0
			$updatedMajorVersion = $majorVersion + 1
		}

        Write-Host "Updating patch version number from: $($patchVersion) to $($updatedPatchVersion)."
        $definition.variables.$PatchVersionVariable.Value = $updatedPatchVersion.ToString()
        Write-Host "Updating minor version number from: $($minorVersion) to $($updatedMinorVersion)."
        $definition.variables.$MinorVersionVariable.Value = $updatedMinorVersion.ToString()
        Write-Host "Updating major version number from: $($majorVersion) to $($updatedMajorVersion)."
		$definition.variables.$MajorVersionVariable.Value = $updatedMajorVersion.ToString()
		
        $definitionJson = $definition | ConvertTo-Json -Depth 50 -Compress

        Write-Verbose "Updating Project Build number with URL: $($defUri)"
        Invoke-RestMethod -Method Put -Uri $defUri -Headers $devOpsHeader -ContentType "application/json" -Body $definitionJson | Out-Null
    }
    else {
        Write-Error "The variables can not be found on the definition: $($MajorVersionVariable), $($MinorVersionVariable), $($PatchVersionVariable)"
    }
}
else {
    Write-Error "Unable to find a build definition for Project $($ProjectName) with the build id: $($buildId)."
}
