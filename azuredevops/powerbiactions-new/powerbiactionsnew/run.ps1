[CmdletBinding()]
param()

BEGIN {
	Write-Output "Starting Power BI Actions extension"
	Trace-VstsEnteringInvocation $MyInvocation

	Import-Module $PSScriptRoot\ps_modules\PowerBi

	$PowerBIMgmtModule = Get-Module MicrosoftPowerBIMgmt.Profile
	If (-not $PowerBIMgmtModule) {
		Install-Module MicrosoftPowerBIMgmt -Scope CurrentUser -Force
	}
	Import-Module MicrosoftPowerBIMgmt
}
PROCESS {
	try {

		$scheme = $Endpoint.Auth.Scheme
		$global:powerbiUrl = $Endpoint.Data.OrganizationType
	
		If ($scheme -eq "UsernamePassword") {
			$username = $Endpoint.Auth.Parameters.Username
			$plainpassWord = $Endpoint.Auth.Parameters.Password
			$password = ConvertTo-SecureString $plainpassWord -AsPlainText -Force
			$cred = New-Object System.Management.Automation.PSCredential $username, $password
			Connect-PowerBIServiceAccount -Environment $powerbiUrl -Credential $cred | Out-Null
		}
		Else {
			$tenantId = $Endpoint.Auth.Parameters.TenantId	
			$clientId = $Endpoint.Auth.Parameters.ClientId
			$plainclientSecret = $Endpoint.Auth.Parameters.ClientSecret
			$clientSecret = ConvertTo-SecureString $plainclientSecret  -AsPlainText -Force
			$cred = New-Object System.Management.Automation.PSCredential $clientId, $clientSecret
	
			Connect-PowerBIServiceAccount -Environment $powerbiUrl -Tenant $tenantId -Credential $cred -ServicePrincipal | Out-Null
		}
	
		#parameters
		$filePattern = Get-VstsInput -Name PowerBIPath
		$workspaceName = Get-VstsInput -Name WorkspaceName
		$overwrite = Get-VstsInput -Name OverWrite -AsBool
		$create = Get-VstsInput -Name Create -AsBool
		$action = Get-VstsInput -Name Action -Require
		$dataset = Get-VstsInput -Name DatasetName
		$oldUrl = Get-VstsInput -Name OldUrl
		$newUrl = Get-VstsInput -Name NewUrl
		$oldServer = Get-VstsInput -Name OldServer
		$newServer = Get-VstsInput -Name NewServer
		$oldDatabase = Get-VstsInput -Name OldDatabase
		$groupObjectIds = Get-VstsInput -Name GroupObjectIds
		$newDatabase = Get-VstsInput -Name NewDatabase
		$AccessRight = Get-VstsInput -Name Permission
		$users = Get-VstsInput -Name Users
		$datasourceType = Get-VstsInput -Name DatasourceType
		$updateAll = Get-VstsInput -Name UpdateAll -AsBool
		$ServicePrincipalString = Get-VstsInput -Name ServicePrincipals 
		$ConnectionString = Get-VstsInput -Name ConnectionString
		
		Write-Debug "WorkspaceName         : $($WorkspaceName)";
		Write-Debug "Create                : $($Create)";

		if ($Action -eq "Workspace") {
			Write-Host "Creating a new Workspace"
			New-PowerBIWorkSpace -WorkspaceName $WorkspaceName
		}
		elseif ($action -eq "Publish") {
			Write-Debug "Fill patern             : $($FilePattern)";
			Publish-PowerBIFile -WorkspaceName $WorkspaceName -Create $Create -FilePattern $FilePattern -Overwrite $Overwrite
		}
		elseif ($Action -eq "DeleteWorkspace") {
			Write-Host "Deleting a Workspace"
			Remove-PowerBIWorkSpace -WorkspaceName $WorkspaceName
		}
		elseif ($Action -eq "AddUsers") {
			Write-Debug "Users             : $($UserString)";
			Write-Host "Adding users to a Workspace"
		
			if ($UserString -eq "") {
				Write-Warning "No users inserted in the variable!"
			}
			else {
				$users = $UserString.Split(",")
				Add-PowerBIWorkspaceUsers -WorkspaceName $WorkspaceName -Users $users -AccessRight $AccessRight -Create $Create
			}
		}
		elseif ($Action -eq "AddSP") {
			Write-Debug "Service principals             : $($ServicePrincipalString)";
			Write-Host "Adding service principals to a Workspace"
		
			if ($ServicePrincipalString -eq "") {
				Write-Warning "No service principals inserted in the variable!"
			}
			else {
				$sps = $ServicePrincipalString.Split(",")
				Add-PowerBIWorkspaceSP -WorkspaceName $WorkspaceName -Sps $sps -AccessRight $AccessRight -Create $Create
			}
		}
		elseif ($Action -eq "AddGroup") {
			Write-Host "Adding security group to a Workspace"
			Write-Debug "Group Ids          	  : $($GroupObjectIds)";
			Write-Debug "Access Rights            : $($AccessRight)";
		
			if ($GroupObjectIds -eq "") {
				Write-Warning "No group inserted in the variable!"
			}
			else {
				$groups = $GroupObjectIds.Split(",")
				Add-PowerBIWorkspaceGroup -WorkspaceName $WorkspaceName -Groups $groups -AccessRight $AccessRight -Create $Create
			}
		}
		elseif ($Action -eq "DataRefresh") {
			Write-Debug "Dataset               : $($Dataset)";

			Write-Host "Trying to refresh Dataset"
			New-DatasetRefresh -WorkspaceName $WorkspaceName -DataSetName $Dataset
		}
		elseif ($Action -eq "UpdateDatasource") {
			Write-Debug "Dataset               : $($Dataset)";
			Write-Host "Trying to update the datasource"
		
			if ($UpdateAll -eq $false -and $Dataset -eq "") {
				Write-Error "When the update all function isn't checked you need to supply a dataset."
			}
			
			Update-PowerBIDatasetDatasources -WorkspaceName $WorkspaceName -OldUrl $OldUrl -NewUrl $NewUrl -DataSetName $Dataset -DatasourceType $DatasourceType -OldServer $OldServer -NewServer $NewServer -OldDatabase $OldDatabase -NewDatabase $NewDatabase -UpdateAll $UpdateAll
		}
		elseif ($Action -eq "SQLDirect") {
			Write-Debug "Dataset               : $($Dataset)";
			Write-Debug "ConnectionString     	: $(if (![System.String]::IsNullOrWhiteSpace($ConnectionString)) { '***'; } else { '<not present>'; })";

			Write-Host "Trying to update a SQL Direct Query"
		
			Update-ConnectionStringDirectQuery -WorkspaceName $WorkspaceName -DatasetName $Dataset -ConnectionString $Connectionstring
		}	
	}
	finally {
		
	}
}
END {
	Write-Output "Done running Power BI Actions extension."
	Trace-VstsLeavingInvocation $MyInvocation
}


