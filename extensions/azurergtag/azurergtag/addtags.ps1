$rgtags = (Get-AzureRmResourceGroup -Name $resourceGroupName).Tags

$rgtagnew = @{}


if($rgtags){

    $rgtagnew = $rgtags
    $keys = $rgtags.Keys
    
    if($keys -inotcontains $key){
        $rgtagnew.Add($key, $value)
    }else{
        $rgtagnew[$key] = $value
    }
}
else{
    $rgtagnew.Add($key, $value)
}

Set-AzureRmResourceGroup -Tag $rgtagnew -Name $resourceGroupName