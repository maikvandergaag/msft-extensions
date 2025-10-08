[CmdletBinding()]
param()

BEGIN {
	Write-Output "Starting BI Reporting Actions extension"
	Trace-VstsEnteringInvocation $MyInvocation

	Write-Output "### Required Module is needed. Importing now..."
	Import-Module $PSScriptRoot\ps_modules\MicrosoftPowerBIMgmt.Profile -Force
	Import-Module $PSScriptRoot\ps_modules\MicrosoftPowerBIMgmt.Workspaces -Force
	Import-Module $PSScriptRoot\ps_modules\MicrosoftPowerBIMgmt.Reports -Force
	Import-Module $PSScriptRoot\ps_modules\MicrosoftPowerBIMgmt.Data -Force

	Write-Host "### Trying to import the incorporated module for PowerBI"
	Import-Module $PSScriptRoot\ps_modules\PowerBI -Force

	try {
		# Force powershell to use TLS 1.2 for all communications.
		[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls11 -bor [System.Net.SecurityProtocolType]::Tls10;
	}
	catch {
		Write-Warning $error
	}
}
PROCESS {

	try {
		$serviceEndpoint = Get-VstsEndpoint -Name (Get-VstsInput -Name "PowerBIServiceEndpoint") -Require
		$verboseVariable = ConvertTo-Json -InputObject $serviceEndpoint
		Write-Verbose "$($verboseVariable)"

		$scheme = $serviceEndpoint.Auth.Scheme
		$global:powerbiUrl = $serviceEndpoint.Url
		$organizationType = $serviceEndpoint.Data.OrganizationType


		If ($scheme -eq "UsernamePassword") {
			$username = $serviceEndpoint.Auth.Parameters.Username
			$plainpassWord = $serviceEndpoint.Auth.Parameters.Password
			$password = ConvertTo-SecureString $plainpassWord -AsPlainText -Force
			$cred = New-Object System.Management.Automation.PSCredential $username, $password
			Connect-PowerBIServiceAccount -Environment $organizationType -Credential $cred | Out-Null
		}
		Else {
			$tenantId = $serviceEndpoint.Auth.Parameters.TenantId
			$clientId = $serviceEndpoint.Auth.Parameters.ClientId
			$plainclientSecret = $serviceEndpoint.Auth.Parameters.ClientSecret
			$plainclientCertificate = $serviceEndpoint.Auth.Parameters.ClientCertificate

			if($plainclientSecret){
				$clientSecret = ConvertTo-SecureString $plainclientSecret  -AsPlainText -Force
				$cred = New-Object System.Management.Automation.PSCredential $clientId, $clientSecret

				Connect-PowerBIServiceAccount -Environment $organizationType -Tenant $tenantId -Credential $cred -ServicePrincipal | Out-Null
			}else{
				Connect-PowerBIServiceAccount -Environment $organizationType -Tenant $tenantId -CertificateThumbprint $plainclientCertificate -ApplicationId $clientId -ServicePrincipal | Out-Null
			}
		}

		#parameters
		$filePattern = Get-VstsInput -Name PowerBIPath
		$workspaceName = Get-VstsInput -Name WorkspaceName
		$overwrite = Get-VstsInput -Name OverWrite -AsBool
		$timeout = Get-VstsInput -Name Timeout
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
		$accessRight = Get-VstsInput -Name Permission
		$users = Get-VstsInput -Name Users
		$datasourceType = Get-VstsInput -Name DatasourceType
		$updateAll = Get-VstsInput -Name UpdateAll -AsBool
		$skipReport = Get-VstsInput -Name SkipReport -AsBool
		$scope = Get-VstsInput -Name Scope
		$servicePrincipalString = Get-VstsInput -Name ServicePrincipals
		$connectionString = Get-VstsInput -Name ConnectionString
		$ParameterInput = Get-VstsInput -Name ParameterInput
		$GatewayName = Get-VstsInput -Name GatewayName
		$ReportName = Get-VstsInput -Name ReportName
		$CapacityName = Get-VstsInput -Name CapacityName
		$Username = Get-VstsInput -Name Username
		$Password = Get-VstsInput -Name Password
		$RefreshScheduleInput = Get-VstsInput -Name RefreshScheduleInput
		$CrossWorkspaceRebinding = Get-VstsInput -Name CrossWorkspaceRebinding -AsBool
		$ReportWorkspaceName = Get-VstsInput -Name ReportWorkspaceName
		$tabularEditorArguments = Get-VstsInput -Name TabularEditorArguments
		$principalType = Get-VstsInput -Name PrincipalType
		$datasetPermissionsUsers = Get-VstsInput -Name DatasetPermissionsUsers
		$datasetPermissionsGroupObjectIds = Get-VstsInput -Name DatasetPermissionsGroupObjectIds
		$datasetAccessRight = Get-VstsInput -Name DatasetAccessRight
		$serverName = Get-VstsInput -Name Server
		$databaseName = Get-VstsInput -Name Database
		$tenantID = Get-VstsInput -Name TenantID		
		$servicePrincipalID = Get-VstsInput -Name ServicePrincipalID
		$servicePrincipalKey = Get-VstsInput -Name ServicePrincipalKey

		
		Write-Debug "WorkspaceName         : $($workspaceName)";
		Write-Debug "Create                : $($Create)";

		if ($action -eq "Workspace") {
			Write-Host "Creating a new Workspace"
			New-PowerBIWorkSpace -WorkspaceName $workspaceName
		}
		elseif ($action -eq "Publish") {
			Write-Debug "File patern             : $($filePattern)";
			Write-Debug "Remove report           : $($SkipReport)";
			
			if($SkipReport){
				Publish-PowerBIFileApi -WorkspaceName $workspaceName -Create $Create -FilePattern $filePattern -Overwrite $overwrite -SkipReport $true
			}else{
				Publish-PowerBIFile -WorkspaceName $workspaceName -Create $Create -FilePattern $filePattern -Overwrite $overwrite -Timeout $timeout
			}
		}
		elseif ($action -eq "DeleteWorkspace") {
			Write-Host "Deleting a Workspace"
			Remove-PowerBIWorkSpace -WorkspaceName $workspaceName
		}
		elseif ($action -eq "AddUsers") {
			Write-Debug "Users             : $($users)";
			Write-Host "Adding users to a Workspace"

			if ($users -eq "") {
				Write-Warning "No users inserted in the variable!"
			}
			else {
				$users = $users.Split(",")
				Add-PowerBIWorkspaceUsers -WorkspaceName $workspaceName -Users $users -AccessRight $accessRight -Create $create
			}
		}
		elseif ($action -eq "AddSP") {
			Write-Debug "Service principals             : $($servicePrincipalString)";
			Write-Host "Adding service principals to a Workspace"

			if ($servicePrincipalString -eq "") {
				Write-Warning "No service principals inserted in the variable!"
			}
			else {
				$sps = $servicePrincipalString.Split(",")
				Add-PowerBIWorkspaceSP -WorkspaceName $workspaceName -Sps $sps -AccessRight $accessRight -Create $create
			}
		}
		elseif ($action -eq "AddGroup") {
			Write-Host "Adding security group to a Workspace"
			Write-Debug "Group Ids          	  : $($groupObjectIds)";
			Write-Debug "Access Rights            : $($accessRight)";

			if ($groupObjectIds -eq "") {
				Write-Warning "No group inserted in the variable!"
			}
			else {
				$groups = $groupObjectIds.Split(",")
				Add-PowerBIWorkspaceGroup -WorkspaceName $workspaceName -Groups $groups -AccessRight $accessRight -Create $create
			}
		}
		elseif ($action -eq "DataRefresh") {
			Write-Debug "Dataset               : $($dataset)";

			if ($updateAll -eq $false -and $dataset -eq "") {
				Write-Error "When the update all function isn't checked you need to supply a dataset."
			}

			Write-Host "Trying to refresh Dataset"
			New-DatasetRefresh -WorkspaceName $workspaceName -DataSetName $dataset -UpdateAll $updateAll
		}
		elseif ($action -eq "UpdateDatasource") {
			Write-Debug "Dataset               : $($dataset)";
			Write-Host "Trying to update the datasource"

			if ($updateAll -eq $false -and $dataset -eq "") {
				Write-Error "When the update all function isn't checked you need to supply a dataset."
			}

			Update-PowerBIDatasetDatasources -WorkspaceName $workspaceName -OldUrl $oldUrl -NewUrl $newUrl -DataSetName $dataset -DatasourceType $datasourceType -OldServer $oldServer -NewServer $newServer -OldDatabase $oldDatabase -NewDatabase $newDatabase -UpdateAll $updateAll
		}
		elseif ($action -eq "SQLDirect") {
			Write-Debug "Dataset               : $($dataset)";
			Write-Debug "ConnectionString     	: $(if (![System.String]::IsNullOrWhiteSpace($connectionString)) { '***'; } else { '<not present>'; })";

			Write-Host "Trying to update a SQL Direct Query"

			Update-ConnectionStringDirectQuery -WorkspaceName $workspaceName -DatasetName $dataset -ConnectionString $connectionstring
		}
		elseif($action -eq "UpdateSqlCreds"){
			Update-BasicSQLDataSourceCredentials -WorkspaceName $workspaceName -ReportName $ReportName -Username $userName -Password $password -Scope $scope
		}
		elseif ($action -eq "UpdateParameters") {
			Write-Debug "Dataset               : $($dataset)";
			Write-Debug "Update Json     	: $($ParameterInput)";

			try {
				ConvertFrom-Json $ParameterInput | Out-Null
			}
			catch {
				Write-Error "Supplied json is not in the correct format!"
			}

			if ($updateAll -eq $false -and $dataset -eq "") {
				Write-Error "When the update all function isn't checked you need to supply a dataset."
			}

			Write-Host "Trying to update the dataset parameters"

			Update-PowerBIDatasetParameters -WorkspaceName $workspaceName -DatasetName $dataset -UpdateAll $updateAll -UpdateValue $ParameterInput
		}
		elseif ($action -eq "TakeOwnership") {
			Write-Debug "Dataset               : $($dataset)";

			Write-Host "Trying to take ownership of the dataset"

			if ($updateAll -eq $false -and $dataset -eq "") {
				Write-Error "When the update all function isn't checked you need to supply a dataset."
			}

			Set-PowerBIDataSetOwnership -WorkspaceName $workspaceName -DatasetName $dataset -UpdateAll $updateAll
		}
		elseif ($action -eq "UpdateGateway") {
			Write-Debug "Dataset               : $($dataset)";
			Write-Debug "UpdateAll             : $($updateAll)";
			Write-Debug "GatewayName           : $($GatewayName)";

			Write-Host "Trying to change the Gateway"

			Update-PowerBIDatasetDatasourcesInGroup -WorkspaceName $workspaceName -DatasetName $dataset -UpdateAll $updateAll -GatewayName $GatewayName
		}
		elseif ($action -eq "BindToGateway") {
			Write-Debug "Dataset               : $($dataset)";
			Write-Debug "UpdateAll             : $($updateAll)";
			#Write-Debug "GatewayName           : $($GatewayName)";
			Write-Host "Trying to bind to Gateway"
			$groupPath = Get-PowerBIGroupPath -WorkspaceName $WorkspaceName
			if ($groupPath) {
				if ($UpdateAll) {
					$sets = Get-PowerBiDataSets -GroupPath $groupPath
					foreach ($set in $sets) {
						$gatewayDatasources = Get-PowerBIDatasetGatewayDatasourceInGroup -Set $set -GroupPath $groupPath #GetBoundGatewayDatasources
						#$result = Invoke-API "$powerbiUrl/datasets/$($set.id)/Default.DiscoverGateways" -Method "Get" -Verbose
						#write-host "Discovered Gateways:" $result.value.Name
						Update-PowerBIDatasetSource -dataset $set -groupPath $groupPath -GatewayDataSources $gatewayDatasources #BindToGateway
					}
				}
				else {
					$set = Get-PowerBiDataSet -GroupPath $groupPath -Name $Dataset
					if ($set) {
						$gatewayDatasources = Get-PowerBIDatasetGatewayDatasourceInGroup -Set $set -GroupPath $groupPath #GetBoundGatewayDatasources
						Update-PowerBIDatasetSource -dataset $set -groupPath $groupPath -GatewayDataSources $gatewayDatasources
					}
					else {
						Write-Warning "Dataset $Dataset could not be found."
					}
				}
			}
			else {
				Write-Error "Workspace: $WorkspaceName could not be found..."
			}

		}
		elseif ($action -eq "DeleteReport") {
			Write-Debug "ReportName               : $($ReportName)";

			Write-Host "Trying to remove a report"

			Remove-PowerBIReport -WorkspaceName $workspaceName -ReportName $ReportName
		}
		elseif ($action -eq "SetCapacity") {
			Write-Debug "Capacity Name				  : $($CapacityName)"

			Write-Host "Trying to set the capacity for the workspace"

			Set-Capacity -WorkspaceName $workspaceName -CapacityName $CapacityName -Create $Create
		}
		elseif($action -eq "RebindReport"){
			Write-Debug "Dataset Name				  : $($dataset)"
			Write-Debug "Report Name				  : $($ReportName)"

			if (!$CrossWorkspaceRebinding) {
				Redo-PowerBIReport -WorkspaceName $workspaceName -DatasetName $dataset -ReportName $ReportName
			} else {
				Redo-PowerBIReportCrossWorkspace -DatasetWorkspaceName $workspaceName -ReportWorkspaceName $ReportWorkspaceName -DatasetName $dataset -ReportName $ReportName
			}
		}
		elseif($action -eq "SetRefreshSchedule"){
			Write-Debug "Dataset Name				  : $($dataset)"
			Write-Debug "Update Json     			  : $($RefreshScheduleInput)"

			try {
				ConvertFrom-Json $RefreshScheduleInput | Out-Null
			}
			catch {
				Write-Error "Supplied json is not in the correct format!"
			}

			Write-Host "Trying to update the dataset refresh schedule"
			Set-RefreshSchedule -WorkspaceName $workspaceName -DatasetName $dataset -ScheduleJSON $RefreshScheduleInput
		}
		elseif($action -eq "DeployTabularModel"){
			Write-Debug "Tabular Editor Args          : $($tabularEditorArguments)"
			Publish-TabularEditor -WorkspaceName $workspaceName -FilePattern $filePattern -TabularEditorArguments $tabularEditorArguments
		}
		elseif($action -eq "SetDatasetPermissions"){
			Write-Debug "Users								: $($datasetPermissionsUsers)"
			Write-Debug "Group Ids						: $($datasetPermissionsGroupObjectIds)"
			Write-Debug "Dataset Name					: $($dataset)"
			Write-Debug "Principal Type				: $($principalType)"
			Write-Debug "Permissions					: $($datasetAccessRight)"

			if ($principalType -eq "User") {
				if($datasetPermissionsUsers -eq "") {
					Write-Error "When the Principal Type User is chosen you have to supply User(s)."
				} else {
					$users = $datasetPermissionsUsers.Split(",")

					Add-PowerBIDatasetPermissions -WorkspaceName $workspaceName -DatasetName $dataset -PrincipalType $principalType -Identifiers $users -AccessRight $datasetAccessRight
				}
			}      

			if ($principalType -eq "Group") {
				if($datasetPermissionsGroupObjectIds -eq "") {
					Write-Error "When the Principal Type Group is chosen you have to supply Group Object Id(s)."
				}
				else {
					$groups = $datasetPermissionsGroupObjectIds.Split(",")

					Add-PowerBIDatasetPermissions -WorkspaceName $workspaceName -DatasetName $dataset -PrincipalType $principalType -Identifiers $groups -AccessRight $datasetAccessRight
				}
			}
		}
		elseif ($action -eq "SetSQLDatasourceSPCredentials") {
			Write-Debug "DatasetName         : $($dataset)";			
			Write-Debug "ServerName          : $($serverName)";
			Write-Debug "DatabaseName        : $($databaseName)";
			Write-Debug "TenantID            : $($tenantID)";
			Write-Debug "ServicePrincipalID  : $($servicePrincipalID)";
			Write-Debug "ServicePrincipalKey : $($servicePrincipalKey)";
			Write-Debug "Scope               : $($scope)";

			Write-Host "Trying to set Service Principal credentials of SQL datasource"

			Set-PowerBIDatasourceCredentials -WorkspaceName $workspaceName -DatasetName $dataset -DatasourceType "Sql" -ServerName $serverName -DatabaseName $databaseName -CredentialType "ServicePrincipal" -TenantID $tenantId -ServicePrincipalID $servicePrincipalID -ServicePrincipalKey $servicePrincipalKey -Scope $scope
		}
	}
	finally {
		Write-Output "Done processing BI Reporting Actions"
	}
}
END {
	Write-Output "Done running BI Reporting Actions extension."
	Trace-VstsLeavingInvocation $MyInvocation
}