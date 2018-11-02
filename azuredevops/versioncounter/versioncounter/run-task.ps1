Trace-VstsEnteringInvocation $MyInvocation

$MinorVersionVariable = Get-VstsInput -Name MinorVersionVariable -Require
$MajorVersionVariable = Get-VstsInput -Name MajorVersionVariable -Require
$PatchVersionVariable = Get-VstsInput -Name PatchVersionVariable -Require
$UpdateMinorVersion = Get-VstsInput -Name UpdateMinorVersion -Require
$MaxValuePathVersion = Get-VstsInput -Name MaxValuePathVersion -Require

$DevOpsPat = Get-VstsInput -Name DevOpsPat -Require

$devOpsUri = $env:SYSTEM_TEAMFOUNDATIONSERVERURI
$projectName = $env:SYSTEM_TEAMPROJECT
$projectId = $env:SYSTEM_TEAMPROJECTID 
$buildId = $env:BUILD_BUILDID

Write-Output "MinorVersionVariable           : $($MinorVersionVariable)";
Write-Output "MajorVersionVariable           : $($MajorVersionVariable)";
Write-Output "PatchVersionVariable           : $($PatchVersionVariable)";
Write-Output "UpdateMinorVersion             : $($UpdateMinorVersion)";
Write-Output "MaxValuePathVersion            : $($MaxValuePathVersion)";
Write-Output "DevOpsPAT             		 : $(if (![System.String]::IsNullOrWhiteSpace($DevOpsPAT)) { '***'; } else { '<not present>'; })"; ;
Write-Output "DevOps Uri        		     : $($devOpsUri)";
Write-Output "Project Name      		     : $($projectName)";
Write-Output "Project Id           			 : $($projectId)";
Write-Output "BuildId            		     : $($buildId)";

$buildUri = "$($devOpsUri)$($projectName)/_apis/build/builds/$($buildId)?api-version=4.1"

# enconding PAT
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "", $DevOpsPAT)))
$devOpsHeader = @{Authorization = ("Basic {0}" -f $base64AuthInfo)}

$buildDef = Invoke-RestMethod -Uri $buildUri -Method Get -ContentType "application/json" -Headers $devOpsHeader

if ($buildDef) {
    $defUri = "$($buildDef.Url)?api-version=4.1"
    $definition = Invoke-RestMethod -Method Get -Uri $defUri -ContentType "application/json" -Headers @devOpsHeader

    if ($definition.variables.$MinorVersionVariable -and $definition.variables.$MajorVersionVariable -and $definition.variables.$PatchVersionVariable) {
		$minorVersion = [convert]::ToInt32($projectDef.variables.$MinorVersionVariable.Value, 10)
		$majorVersion = [convert]::ToInt32($projectDef.variables.$MajorVersionVariable.Value, 10)
		$patchVersion = [convert]::ToInt32($projectDef.variables.$PatchVersionVariable.Value, 10)
		
		$updatedPatchVersion = $patchVersion + 1

		if(($MaxValuePathVersion -ne 0) -and ($updatedPatchVersion -gt $MaxValuePathVersion) -and $UpdateMinorVersion){
			$updatedPatchVersion = 0
			$updatedMinorVersion = $minorVersion + 1
		}

		$definition.variables.$PatchVersionVariable.Value = $updatedPatchVersion.ToString()
		$definition.variables.$MinorVersionVariable.Value = $updatedMinorVersion.ToString()
		
        $definitionJson = $definition | ConvertTo-Json -Depth 50 -Compress

        $updateUri = "$($definition.Url)?api-version=4.1"
        Write-Verbose "Updating Project Build number with URL: $($updateUri)"
        Invoke-RestMethod -Method Put -Uri $updateUri -Headers $header -ContentType "application/json" -Body $definitionJson | Out-Null
    }
    else {
        Write-Error "The variables can not be found on the definition: $($MajorVersionVariable), $($MinorVersionVariable), $($PatchVersionVariable)"
    }
}
else {
    Write-Error "Unable to find a build definition for Project $($ProjectName) with the build id: $($buildId)."
}
