[CmdletBinding()]
param()

# For more information on the VSTS Task SDK:
# https://github.com/Microsoft/vsts-task-lib

#Login-AzureRmAccount 
$resourceGroupName = "gaag-rg-dev-webapp"
$Key = "test22ss"
$Value = "test255"
$action = "Remove"

Write-Host "Resource group: $resourceGroupName"
Write-Host "Key: $key"
Write-Host "Value: $value"

if($action -eq "Add"){
    Write-Host "Adding the $key to the tags"
	.\addtags.ps1
}elseif($action -eq "Remove"){
    Write-Host "Removing the $key from the tags"
	.\removetags.ps1
}
