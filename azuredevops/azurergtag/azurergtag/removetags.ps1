$rgtags = (Get-AzureRmResourceGroup -Name $resourceGroupName).Tags
$rgtagnew = @{}

if($rgtags){

    $rgtagnew = $rgtags
    $keys = $rgtags.Keys
    
    if($keys -inotcontains $key){
        
    }else{
        $rgtagnew.Remove($key)
		Set-AzureRmResourceGroup -Tag $rgtagnew -Name $resourceGroupName
    }
}

