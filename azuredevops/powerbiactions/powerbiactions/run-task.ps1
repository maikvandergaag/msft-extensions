[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false)][String]$Username,
    [Parameter(Mandatory = $false)][String]$FilePattern,
    [Parameter(Mandatory = $true)][String]$ClientID,
    [Parameter(Mandatory = $false)][SecureString]$PassWord,
    [Parameter(Mandatory = $true)][String]$WorkspaceName,
    [Parameter(Mandatory = $false)][Boolean]$Overwrite,
    [Parameter(Mandatory = $false)][Boolean]$Create,
    [Parameter(Mandatory = $false)][String]$Action,
    [Parameter(Mandatory = $false)][String]$Dataset,
    [Parameter(Mandatory = $false)][String]$UserString,
    [Parameter(Mandatory = $false)][String]$AccessRight,
    [Parameter(Mandatory = $false)][String]$GroupObjectIds,
    [Parameter(Mandatory = $false)][String]$OldServer,
    [Parameter(Mandatory = $false)][String]$NewServer,
    [Parameter(Mandatory = $false)][String]$OldDatabase,
    [Parameter(Mandatory = $false)][String]$NewDatabase,
    [Parameter(Mandatory = $false)][String]$DatasourceType,
    [Parameter(Mandatory = $false)][String]$OldUrl,
    [Parameter(Mandatory = $false)][String]$NewUrl,
    [Parameter(Mandatory = $false)][Boolean]$UpdateAll,
    [Parameter(Mandatory = $false)][SecureString]$ClientSecret,
    [Parameter(Mandatory = $false)][String]$TenantId,
    [Parameter(Mandatory = $false)][String]$ServicePrincipalString,
    [Parameter(Mandatory = $false)][String]$ConnectionString
)

try {
    # Force powershell to use TLS 1.2 for all communications.
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls11 -bor [System.Net.SecurityProtocolType]::Tls10;
}
catch {
    Write-Warning $error
}

Write-Debug "FilePattern           : $($FilePattern)";
Write-Debug "ClientID         	   : $($ClientId)";
Write-Debug "PassWord              : $(if (![System.String]::IsNullOrWhiteSpace($PassWord)) { '***'; } else { '<not present>'; })";
Write-Debug "Username              : $($Username)";
Write-Debug "WorkspaceName         : $($WorkspaceName)";
Write-Debug "Overwrite             : $($Overwrite)";
Write-Debug "Create                : $($Create)";
Write-Debug "Action                : $($Action)";
Write-Debug "Dataset               : $($Dataset)";
Write-Debug "Users                 : $($UserString)";
Write-Debug "AccessRight           : $($AccessRight)";
Write-Debug "GroupObjectIds        : $($GroupObjectIds)";
Write-Debug "OldServer             : $($OldServer)";
Write-Debug "NewServer             : $($NewServer)";
Write-Debug "OldDatabase           : $($OldDatabase)";
Write-Debug "NewDatabase           : $($NewDatabase)";
Write-Debug "OldUrl                : $($OldUrl)";
Write-Debug "NewUrl                : $($NewUrl)";
Write-Debug "DatasourceType        : $($DatasourceType)";
Write-Debug "UpdateAll             : $($UpdateAll)";
Write-Debug "ClientSecret          : $($ClientSecret)";
Write-Debug "TenantId              : $($TenantId)";
Write-Debug "Service Principals    : $($ServicePrincipalString)";
Write-Debug "ConnectionString     	: $(if (![System.String]::IsNullOrWhiteSpace($ConnectionString)) { '***'; } else { '<not present>'; })";

#AADToken
$ResourceUrl = "https://analysis.windows.net/powerbi/api"
#Write-Host "Getting AAD Token for user: $UserName"

if (!$TenantId) {
    Write-Host "Logging in with a User Principal"
    $tokenResult = Get-ADALToken -Resource $ResourceUrl -ClientId $ClientId -UserId $Username -Password $PassWord
    $token = $tokenResult.AccessToken
}
else {
    Write-Host "Logging in with a Service Principal"
    $tokenResult = Get-ADALToken -Resource $ResourceUrl -ClientId $ClientId -ClientSecret $ClientSecret -TenantId $TenantId
    $token = $tokenResult.AccessToken
}

if ($Action -eq "Workspace") {
    Write-Host "Creating a new Workspace"
    New-PowerBIWorkSpace -WorkspaceName $WorkspaceName -AccessToken $token
}
elseif ($action -eq "Publish") {
    Write-Host "Publishing PowerBI FIle: $FilePattern, in workspace: $WorkspaceName with user: $Username"
    Publish-PowerBIFile -WorkspaceName $WorkspaceName -Create $Create -AccessToken $token -FilePattern $FilePattern -Overwrite $Overwrite
}
elseif ($Action -eq "DeleteWorkspace") {
    Write-Host "Deleting a Workspace"
    Remove-PowerBIWorkSpace -WorkspaceName $WorkspaceName -AccessToken $token
}
elseif ($Action -eq "AddUsers") {
    Write-Host "Adding users to a Workspace"

    if ($UserString -eq "") {
        Write-Warning "No users inserted in the variable!"
    }
    else {
        $users = $UserString.Split(",")
        Add-PowerBIWorkspaceUsers -WorkspaceName $WorkspaceName -Users $users -AccessToken $token -AccessRight $AccessRight -Create $Create
    }
}
elseif ($Action -eq "AddSP") {
    Write-Host "Adding service principals to a Workspace"

    if ($ServicePrincipalString -eq "") {
        Write-Warning "No service principals inserted in the variable!"
    }
    else {
        $sps = $ServicePrincipalString.Split(",")
        Add-PowerBIWorkspaceSP -WorkspaceName $WorkspaceName -Sps $sps -AccessToken $token -AccessRight $AccessRight -Create $Create
    }
}
elseif ($Action -eq "AddGroup") {
    Write-Host "Adding security group to a Workspace"

    if ($GroupObjectIds -eq "") {
        Write-Warning "No group inserted in the variable!"
    }
    else {
        $groups = $GroupObjectIds.Split(",")
        Add-PowerBIWorkspaceGroup -WorkspaceName $WorkspaceName -Groups $groups -AccessToken $token -AccessRight $AccessRight -Create $Create
    }
}
elseif ($Action -eq "DataRefresh") {
    Write-Host "Trying to refresh Dataset"
    New-DatasetRefresh -WorkspaceName $WorkspaceName -DataSetName $Dataset -AccessToken $token
}
elseif ($Action -eq "UpdateDatasource") {
    Write-Host "Trying to update the datasource"

    if ($UpdateAll -eq $false -and $Dataset -eq "") {
        Write-Error "When the update all function isn't checked you need to supply a dataset."
    }
    
    Update-PowerBIDatasetDatasources -WorkspaceName $WorkspaceName -OldUrl $OldUrl -NewUrl $NewUrl -DataSetName $Dataset -AccessToken $token -DatasourceType $DatasourceType -OldServer $OldServer -NewServer $NewServer -OldDatabase $OldDatabase -NewDatabase $NewDatabase -UpdateAll $UpdateAll
}
elseif ($Action -eq "SQLDirect") {
    Write-Host "Trying to update a SQL Direct Query"

    Update-ConnectionStringDirectQuery -WorkspaceName $WorkspaceName -AccessToken $token -DatasetName $Dataset -ConnectionString $Connectionstring
}
