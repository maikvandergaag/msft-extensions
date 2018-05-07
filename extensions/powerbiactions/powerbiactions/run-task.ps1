[CmdletBinding()]
param()

# For more information on the VSTS Task SDK:
# https://github.com/Microsoft/vsts-task-lib
Trace-VstsEnteringInvocation $MyInvocation

Import-Module $PSScriptRoot\ps_modules\PowerBi

try {
    # Get VSTS input values
    $userName = Get-VstsInput -Name Username -Require
	$filePattern = Get-VstsInput -Name PowerBIPath
	$passWord = Get-VstsInput -Name Password -Require
	$clientId = Get-VstsInput -Name ClientId -Require
	$groupName = Get-VstsInput -Name GroupName
	$overwrite = Get-VstsInput -Name OverWrite
	$connectionstring = Get-VstsInput -Name ConnectionString
	$create = Get-VstsInput -Name Create
	$action= Get-VstsInput -Name Action -Require
	$dataset = Get-VstsInput -Name Dataset
	
	#AADToken
	Write-Host "Getting AAD Token for user: $userName"
	$token = Get-AADToken -username $userName -Password $passWord -clientId $clientId -resource $resourceUrl -Verbose

	$groupsPath = ""
	if ($groupName -eq "me") {
		$groupsPath = "/myorg"
	} else {
		#Current groups
		Write-Host "Getting PowerBI group properties; $groupName"
		$group = Get-PowerBiGroup -GroupName $groupName -AccessToken $token -Verbose

		if($create -And !$group){
			$group = Create-WorkSpace -GroupName $groupname -AccessToken $token
		}

		$groupId = $group.Id

		$groupsPath = "/myorg/groups/$groupId"
	}
	
	if($action -eq "DirectQuery"){
		Write-Host "Updating Dataset"
		Update-ConnectionStringDirectQuery -GroupPath $groupsPath -AccessToken $token -DataSetName $dataset -ConnectionString $connectionstring
	}
	elseif($action -eq "Upload"){
 		.\publishpowerbi.ps1
	}
} 
finally {
    Trace-VstsLeavingInvocation $MyInvocation
}