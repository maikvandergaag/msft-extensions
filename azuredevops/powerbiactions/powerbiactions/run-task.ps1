[CmdletBinding()]
param()
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

	Write-Output "FilePattern           : $($filePattern)";
	Write-Output "ClientID         		: $($clientId)";
	Write-Output "PassWord            	: $(if (![System.String]::IsNullOrWhiteSpace($passWord)) { '***'; } else { '<not present>'; })";
	Write-Output "Username             	: $($username)";
	Write-Output "GroupName             : $($groupName)";
	Write-Output "Overwrite             : $($overwrite)";
	Write-Output "Connectionstring      : $(if (![System.String]::IsNullOrWhiteSpace($connectionstring)) { '***'; } else { '<not present>'; })";
	Write-Output "Create                : $($create)";
	Write-Output "Action                : $($action)";
	Write-Output "Dataset               : $($dataset)";

	try {
		# Force powershell to use TLS 1.2 for all communications.
		[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls11 -bor [System.Net.SecurityProtocolType]::Tls10;
	}
	catch {
		Write-Warning $error
	}



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