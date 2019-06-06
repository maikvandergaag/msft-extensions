[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)][String]$ResourceGroupName,
    [Parameter(Mandatory = $false)][Hashtable]$Tags,
    [Parameter(Mandatory = $true)][String]$Location,
    [Parameter(Mandatory = $true)][Bool]$Lock
)

Write-Host "Trying to create or update Resource Group: $ResourceGroupName"
Write-Host "Checking the resource group: $ResourceGroupName"

$group = Get-AzResourceGroup -Name $ResourceGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue

if ($notPresent){
    Write-Host "Resource Group does not exist trying to create it in: $location" -ForegroundColor Green

    if($Tags){
        New-AzResourceGroup -Name $ResourceGroupName -Location "$location" -Tag $Tags
    }else{
        New-AzResourceGroup -Name $ResourceGroupName -Location "$location"
    }

    if($lock){
        New-AzResourceLock -ResourceGroupName $ResourceGroupName -LockName "$ResourceGroupName" -LockNotes "Do not delete!" -LockLevel CanNotDelete -Force
    }
}
else{
    if($Tags){
        Write-Host "Resource Group already exists trying to update the tags" -ForegroundColor Green
        $update = $false;
        $currentTags = $group.Tags

        foreach($tagKey in $Tags.Keys){
            if($currentTags.ContainsKey($tagKey)){
                $value = $currentTags[$tagKey]

                if(!($value -eq $Tags[$tagKey])){
                    $currentTags[$tagKey] = $Tags[$tagKey]
                    $update = $true
                }
            }else{
                $currentTags.Add($tagKey, $Tags[$tagKey])
                $update = $true
            }
        }

        if($update){
            Set-AzResourceGroup -ResourceGroupName "$ResourceGroupName" -Tags $currentTags
        }
    }
}