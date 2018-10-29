Import-Module $PSScriptRoot\ps_modules\PowerBi -Force

$userName = "vsts@familie-vandergaag.nl"
$filePattern = "test.pbix"
$passWord = "Ch@rl0tte"
$clientId = "ee12c9e9-d1cf-4036-8da4-a728ad4b8a67"
$groupName = "Test"
$overwrite = $true
$create = $true
$action = "Update Connection String"	

$token = Get-AADToken -UserName $userName -Password $passWord -ClientId $clientId -resource $resourceUrl

$group = Get-PowerBiGroup -GroupName $groupName -AccessToken $token -Verbose

$set = Get-PowerBiDataSet -GroupId $group.Id -AccessToken $token -Name "Test"
$setId = $set.Id

$url = $powerbiUrl + "/datasets/$setId/parameters"
$result = Invoke-API -Url $url -Method "Get" -AccessToken $AccessToken -Verbose

$res=$result.value | Select-Object *,@{N="Dataset";E={$dataset}}
$res
