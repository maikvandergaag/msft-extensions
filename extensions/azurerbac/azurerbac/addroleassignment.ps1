function SetAssigment{
    Param(
        [parameter(Mandatory=$true)][string]$Role,
        [parameter(Mandatory=$true)][guid]$ObjectId,
        [parameter(Mandatory=$true)][string]$ResourceGroupName,
        [parameter(Mandatory=$true)][string]$BreakonException
    )
    
	$getting = $false;

    Try{
		$ErrorActionPreference = "Stop";

		$assignment = $null
		$assignment = Get-AzureRmRoleAssignment -ObjectId $ObjectId -RoleDefinitionName $Role -ResourceGroupName $ResourceGroupName
		$getting = $true;

			if($assignment -eq $null){
				Write-Host "Setting new assigment for $Role and $ObjectId";
				New-AzureRmRoleAssignment  -ObjectId $ObjectId -RoleDefinitionName $Role -ResourceGroupName $ResourceGroupName
			}else{
				Write-Host "Assignment already exists"
			}

    }
	Catch [Microsoft.Rest.Azure.CloudException]{
		if(!$getting){
			Write-Host "Assignment already exists"
		}
	}
	Catch{
         $ErrorMessage = $_.Exception.Message
         Write-Host $ErrorMessage -ForegroundColor Red
         if($BreakonException){
            throw $_
         }
    }

    Write-Host "Assignment done"
}

Write-Host "Setting RBAC for group: $resourceGroupName";

$items = $null

if($action -eq 'Users'){
    Write-Host "Setting RBAC for specific users";
    $items = $users.Split(",");
}elseif($action -eq 'Groups'){
    Write-Host "Setting RBAC for specific groups";
    $items = $groups.Split(",");
}

if($items -ne $null){
    foreach($item in $items){

        $adObject = $null

        if($action -eq 'Users'){
			Write-Host "Getting user $item";
            $adObject = Get-AzureRmADUser -UserPrincipalName $item
        }elseif($action -eq 'Groups'){
			Write-Host "Getting group $item";
            $adObject = Get-AzureRmADGroup -SearchString $item
        }

        if($adObject -ne $null){
            SetAssigment -Role $role -ObjectId $adObject.Id -ResourceGroupName $resourceGroupName -BreakonException $failonError                      
        }else{
            $message = "Can't find ad object: $item"

            if($failonError){
                throw $message
            }else{
                Write-Host $message -ForegroundColor Red
            }
        }
    }
}

   
