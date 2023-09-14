[CmdletBinding()]
param(
    [string]$WorkspaceName, [string]$Action, [string]$Scheme, [string]$Username, [string]$PassWord, [string]$TenantId, [string]$ClientId, [string]$ClientSecret,
    [string]$ClientCertificate, [string]$OrganizationType, [string]$FilePattern, [bool]$Overwrite, [bool]$Create, [string]$Dataset, [string]$OldUrl, [string]$NewUrl,
    [string]$OldServer, [string]$NewServer, [string]$OldDatabase, [string]$GroupObjectIds, [string]$NewDatabase, [string]$AccessRight, [string]$Users, [string]$DatasourceType,
    [bool]$UpdateAll, [bool]$SkipReport, [string]$IndividualString, [string]$ServicePrincipalString, [string]$ConnectionString, [string]$ParameterInput,
    [string]$GatewayName, [string]$ReportName, [string]$CapacityName, [string]$InputUsername, [string]$InputPassword, [string]$RefreshScheduleInput,
    [bool]$CrossWorkspaceRebinding, [string]$ReportWorkspaceName, [string]$TabularEditorArguments, [string]$PrincipalType, [string]$DatasetPermissionsUsers,
    [string]$DatasetPermissionsGroupObjectIds, [string]$DatasetAccessRight, [string]$EndpointUrl
)
BEGIN {
    Write-Host "### The required modules for this action need to be imported. Importing now..."
    Import-Module $PSScriptRoot/ps_modules/MicrosoftPowerBIMgmt.Profile -Force
    Import-Module $PSScriptRoot/ps_modules/MicrosoftPowerBIMgmt.Workspaces -Force
    Import-Module $PSScriptRoot/ps_modules/MicrosoftPowerBIMgmt.Reports -Force
    Import-Module $PSScriptRoot/ps_modules/MicrosoftPowerBIMgmt.Data -Force
    Import-Module $PSScriptRoot/ps_modules/PowerBI/powerbi.psm1 -Force
    Write-Host "### The required modules for this action have been imported."

    try {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls11 -bor [System.Net.SecurityProtocolType]::Tls10;
    }
    catch {
        Write-Warning $error
    }

	$global:powerbiUrl = $EndpointUrl
}
PROCESS {

    try {

		If ($Scheme -eq "UsernamePassword") {
			$securePassword = ConvertTo-SecureString $PassWord -AsPlainText -Force
			$cred = New-Object System.Management.Automation.PSCredential $Username, $securePassword
			Connect-PowerBIServiceAccount -Environment $OrganizationType -Credential $cred | Out-Null
		}
		Else {
			if($ClientSecret){
				$SecureClientSecret = ConvertTo-SecureString $ClientSecret  -AsPlainText -Force
				$cred = New-Object System.Management.Automation.PSCredential $ClientId, $SecureClientSecret
                Write-Verbose "Logging in into tenant: $TenantId with organization type: $OrganizationType with ClientId and ClientSecret"
				Connect-PowerBIServiceAccount -Environment $OrganizationType -Tenant $TenantId -Credential $cred -ServicePrincipal | Out-Null
			}else{
                Write-Verbose "Logging in into tenant: $TenantId with organization type: $OrganizationType with ClientId and ClientCertificate"
				Connect-PowerBIServiceAccount -Environment $OrganizationType -Tenant $TenantId -CertificateThumbprint $ClientCertificate -ApplicationId $ClientId -ServicePrincipal | Out-Null
			}
		}

		$individual = $false
		if($IndividualString -eq "Individual"){
			$individual = $true
		}


		if ($Action -eq "Workspace") {
			Write-Host "Creating a new Workspace"
			New-PowerBIWorkSpace -WorkspaceName $WorkspaceName
		}
		elseif ($Action -eq "Publish") {
			Write-Host "File patern             : $($FilePattern)";
			Write-Host "Remove report           : $($SkipReport)";

			if($SkipReport){
				Publish-PowerBIFileApi -WorkspaceName $WorkspaceName -Create $Create -FilePattern $FilePattern -Overwrite $Overwrite -SkipReport $true
			}else{
				Publish-PowerBIFile -WorkspaceName $WorkspaceName -Create $Create -FilePattern $FilePattern -Overwrite $Overwrite
			}
		}
		elseif ($Action -eq "DeleteWorkspace") {
			Write-Host "Deleting a Workspace"
			Remove-PowerBIWorkSpace -WorkspaceName $WorkspaceName
		}
		elseif ($Action -eq "AddUsers") {
			Write-Debug "Users             : $($Users)";
			Write-Host "Adding users to a Workspace"

			if ($Users -eq "") {
				Write-Warning "No users inserted in the variable!"
			}
			else {
				$UsersSplitted = $Users.Split(",")
				Add-PowerBIWorkspaceUsers -WorkspaceName $WorkspaceName -Users $UsersSplitted -AccessRight $AccessRight -Create $Create
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

			if ($UpdateAll -eq $false -and $Dataset -eq "") {
				Write-Error "When the update all function isn't checked you need to supply a dataset."
			}

			Write-Host "Trying to refresh Dataset"
			New-DatasetRefresh -WorkspaceName $WorkspaceName -DataSetName $Dataset -UpdateAll $UpdateAll
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
		elseif($Action -eq "UpdateSqlCreds"){
			Update-BasicSQLDataSourceCredentials -WorkspaceName $WorkspaceName -ReportName $ReportName -Username $InputUsername -Password $InputPassword -Individual $individual
		}
		elseif ($Action -eq "UpdateParameters") {
			Write-Debug "Dataset               : $($Dataset)";
			Write-Debug "Update Json     	: $($ParameterInput)";

			try {
				ConvertFrom-Json $ParameterInput | Out-Null
			}
			catch {
				Write-Error "Supplied json is not in the correct format!"
			}

			if ($UpdateAll -eq $false -and $Dataset -eq "") {
				Write-Error "When the update all function isn't checked you need to supply a dataset."
			}

			Write-Host "Trying to update the dataset parameters"

			Update-PowerBIDatasetParameters -WorkspaceName $WorkspaceName -DatasetName $Dataset -UpdateAll $UpdateAll -UpdateValue $ParameterInput
		}
		elseif ($Action -eq "TakeOwnership") {
			Write-Debug "Dataset               : $($Dataset)";

			Write-Host "Trying to take ownership of the dataset"

			if ($UpdateAll -eq $false -and $Dataset -eq "") {
				Write-Error "When the update all function isn't checked you need to supply a dataset."
			}

			Set-PowerBIDataSetOwnership -WorkspaceName $WorkspaceName -DatasetName $Dataset -UpdateAll $UpdateAll
		}
		elseif ($Action -eq "UpdateGateway") {
			Write-Debug "Dataset               : $($Dataset)";
			Write-Debug "UpdateAll             : $($UpdateAll)";
			Write-Debug "GatewayName           : $($GatewayName)";

			Write-Host "Trying to change the Gateway"

			Update-PowerBIDatasetDatasourcesInGroup -WorkspaceName $WorkspaceName -DatasetName $Dataset -UpdateAll $UpdateAll -GatewayName $GatewayName
		}
		elseif ($Action -eq "DeleteReport") {
			Write-Debug "ReportName               : $($ReportName)";

			Write-Host "Trying to remove a report"

			Remove-PowerBIReport -WorkspaceName $WorkspaceName -ReportName $ReportName
		}
		elseif ($Action -eq "SetCapacity") {
			Write-Debug "Capacity Name				  : $($CapacityName)"

			Write-Host "Trying to set the capacity for the workspace"

			Set-Capacity -WorkspaceName $WorkspaceName -CapacityName $CapacityName -Create $Create
		}
		elseif($Action -eq "RebindReport"){
			Write-Debug "Dataset Name				  : $($Dataset)"
			Write-Debug "Report Name				  : $($ReportName)"

			if (!$CrossWorkspaceRebinding) {
				Redo-PowerBIReport -WorkspaceName $WorkspaceName -DatasetName $Dataset -ReportName $ReportName
			} else {
				Redo-PowerBIReportCrossWorkspace -DatasetWorkspaceName $WorkspaceName -ReportWorkspaceName $ReportWorkspaceName -DatasetName $Dataset -ReportName $ReportName
			}
		}
		elseif($Action -eq "SetRefreshSchedule"){
			Write-Debug "Dataset Name				  : $($Database)"
			Write-Debug "Update Json     			  : $($RefreshScheduleInput)"

			try {
				ConvertFrom-Json $RefreshScheduleInput | Out-Null
			}
			catch {
				Write-Error "Supplied json is not in the correct format!"
			}

			Write-Host "Trying to update the dataset refresh schedule"
			Set-RefreshSchedule -WorkspaceName $WorkspaceName -DatasetName $Dataset -ScheduleJSON $RefreshScheduleInput
		}
		elseif($Action -eq "DeployTabularModel"){
			Write-Debug "Tabular Editor Args          : $($TabularEditorArguments)"
			Publish-TabularEditor -WorkspaceName $WorkspaceName -FilePattern $FilePattern -TabularEditorArguments $TabularEditorArguments
		}
		elseif($Action -eq "SetDatasetPermissions"){
			Write-Debug "Users								: $($DatasetPermissionsUsers)"
			Write-Debug "Group Ids						: $($DatasetPermissionsGroupObjectIds)"
			Write-Debug "Dataset Name					: $($Dataset)"
			Write-Debug "Principal Type				: $($PrincipalType)"
			Write-Debug "Permissions					: $($DatasetAccessRight)"

			if ($PrincipalType -eq "User") {
				if($DatasetPermissionsUsers -eq "") {
					Write-Error "When the Principal Type User is chosen you have to supply User(s)."
				} else {
					$users = $DatasetPermissionsUsers.Split(",")

					Add-PowerBIDatasetPermissions -WorkspaceName $WorkspaceName -DatasetName $Dataset -PrincipalType $PrincipalType -Identifiers $users -AccessRight $DatasetAccessRight
				}
			}      

			if ($PrincipalType -eq "Group") {
				if($DatasetPermissionsGroupObjectIds -eq "") {
					Write-Error "When the Principal Type Group is chosen you have to supply Group Object Id(s)."
				}
				else {
					$groups = $DatasetPermissionsGroupObjectIds.Split(",")

					Add-PowerBIDatasetPermissions -WorkspaceName $WorkspaceName -DatasetName $Dataset -PrincipalType $PrincipalType -Identifiers $groups -AccessRight $DatasetAccessRight
				}
			}
		}
	}
	finally {
		Write-Output "Done processing Power BI Actions with action: $Action"
	}
}END {
    Write-Host "### Execution of this task is done."
}

