Write-Host "Setting Parameters -  Cluster: $cluster, Database: $database. Details -  ClientId: $clientId, TenantId: $tenantId, GroupId: $groupId, DatasetId: $datasetId"

Write-Host "Trying to get access token"
$token = Get-Token -username $userName -Password $passWord -clientId $clientId -TenantId $tenantId
Write-Host "Token recieved!"

Write-Host "Setting parameters"
Set-Parameters -GroupId $groupId -DatasetId $datasetId -AccessToken $token -ParamsArray $paramsArray
Write-Host "Settings parameters succeeded."

if($refresh) {
    Write-Host "Triggering dataset refresh!"
    Set-TriggerRefresh -GroupId $groupId -DatasetId $datasetId -AccessToken $token
    Write-Host "Trigger dataset refresh succeeded."
}
