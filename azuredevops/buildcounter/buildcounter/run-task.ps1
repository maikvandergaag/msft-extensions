Trace-VstsEnteringInvocation $MyInvocation

$VariableName = Get-VstsInput -Name VariableName -Require
$DevOpsPat = Get-VstsInput -Name DevOpsPat -Require

$devOpsUri = $env:SYSTEM_TEAMFOUNDATIONSERVERURI
$projectName = $env:SYSTEM_TEAMPROJECT
$projectId = $env:SYSTEM_TEAMPROJECTID 
$buildId = $env:BUILD_BUILDID

Write-Output "VariableName           : $($VariableName)";
Write-Output "DevOpsPAT              : $(if (![System.String]::IsNullOrWhiteSpace($DevOpsPAT)) { '***'; } else { '<not present>'; })";;
Write-Output "DevOps Uri             : $($devOpsUri)";
Write-Output "Project Name           : $($projectName)";
Write-Output "Project Id             : $($projectId)";
Write-Output "BuildId                : $($buildId)";

try
{
	$buildUri = "$($devOpsUri)$($projectName)/_apis/build/builds/$($buildId)?api-version=4.1"

	# enconding PAT
	$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "", $DevOpsPAT)))
	$devOpsHeader = @{Authorization = ("Basic {0}" -f $base64AuthInfo)}

	$buildDef = Invoke-RestMethod -Uri $buildUri -Method Get -ContentType "application/json" -Headers $devOpsHeader

	if ($buildDef){
		$item = $projectDef.variables.$VariableName

		if ($item){
			[int]$counter = [convert]::ToInt32($item.Value, 10)
			$updatedCounter = $counter + 1

			Write-Host "Project Build Number for '$ProjectName' is $counter. Will be updating to $updatedCounter"

			$projectDef.variables.ProjectBuildNumber.Value = $updatedCounter.ToString()


		}else{
			Write-Error "Unable to find a variable called '$valueName' in Project $ProjectName. Please check the config and try again."
		}
	}
	else{
		Write-Error "Unable to find a build definition for Project $($ProjectName) with the build id: $($buildId)."
	}

	# Update the value and update VSTS
	$projectDef.variables.ProjectBuildNumber.Value = $updatedCounter.ToString()
	$projectDefJson = $projectDef | ConvertTo-Json -Depth 50 -Compress

	$putUrl = "$($projectDef.Url)?api-version=4.1"
	Write-Verbose "Updating Project Build number with URL: $putUrl"
	Invoke-RestMethod -Method Put -Uri $putUrl -Headers $header -ContentType "application/json" -Body $projectDefJson | Out-Null
}
catch{
   $error = $_.Exception.Message
   Write-Verbose "Unable to get the authScheme $error" 
}