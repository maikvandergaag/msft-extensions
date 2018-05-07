 
Import-Module $PSScriptRoot\ps_modules\PowerBi -Force

# Get VSTS input values
$userName = ""
$filePattern = "test.pbix"
$passWord = ""
$clientId = ""
$groupName = "Sub Matters Experts 2"
$overwrite = $true
$create = $true
$action = "Upload"

## Dataset update
$connectionstring = "data source=MyAzureDB.database.windows.net;initial catalog=Sample2;persist security info=True;encrypt=True;trustservercertificate=Fals"

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
    


