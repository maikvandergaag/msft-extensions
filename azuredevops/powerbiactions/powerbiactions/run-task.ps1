[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)][String]$Username,
    [Parameter(Mandatory = $false)][String]$FilePattern,
    [Parameter(Mandatory = $true)][String]$ClientID,
    [Parameter(Mandatory = $true)][SecureString]$PassWord,
    [Parameter(Mandatory = $true)][String]$WorkspaceName,
    [Parameter(Mandatory = $false)][Boolean]$Overwrite,
    [Parameter(Mandatory = $false)][String]$Connectionstring,
    [Parameter(Mandatory = $false)][Boolean]$Create,
    [Parameter(Mandatory = $false)][String]$Action,
    [Parameter(Mandatory = $false)][String]$Dataset,
    [Parameter(Mandatory = $false)][String]$UserString,
    [Parameter(Mandatory = $false)][String]$AccessRight,
    [Parameter(Mandatory = $false)][String]$OldServer,
    [Parameter(Mandatory = $false)][String]$NewServer,
    [Parameter(Mandatory = $false)][String]$OldDatabase,
    [Parameter(Mandatory = $false)][String]$NewDatabase,
    [Parameter(Mandatory = $false)][String]$DatasourceType,
    [Parameter(Mandatory = $false)][String]$OldUrl,
    [Parameter(Mandatory = $false)][String]$NewUrl,
    [Parameter(Mandatory = $false)][Boolean]$UpdateAll
)

try {
	# Force powershell to use TLS 1.2 for all communications.
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls11 -bor [System.Net.SecurityProtocolType]::Tls10;
}
catch {
	Write-Warning $error
}

Write-Output "FilePattern           : $($FilePattern)";
Write-Output "ClientID         		: $($ClientId)";
Write-Output "PassWord            	: $(if (![System.String]::IsNullOrWhiteSpace($PassWord)) { '***'; } else { '<not present>'; })";
Write-Output "Username             	: $($Username)";
Write-Output "WorkspaceName         : $($WorkspaceName)";
Write-Output "Overwrite             : $($Overwrite)";
Write-Output "Create                : $($Create)";
Write-Output "Action                : $($Action)";
Write-Output "Dataset               : $($Dataset)";
Write-Output "Users                 : $($UserString)";
Write-Output "AccessRight           : $($AccessRight)";
Write-Output "OldServer             : $($OldServer)";
Write-Output "NewServer             : $($NewServer)";
Write-Output "OldDatabase           : $($OldDatabase)";
Write-Output "NewDatabase           : $($NewDatabase)";
Write-Output "OldUrl                : $($OldUrl)";
Write-Output "NewUrl                : $($NewUrl)";
Write-Output "DatasourceType        : $($DatasourceType)";
Write-Output "UpdateAll             : $($UpdateAll)";

if($UpdateAll -eq $false -and $Dataset -eq ""){
    Write-Error "When the update all function isn't checked you need to supply a dataset."
}

#AADToken
$ResourceUrl = "https://analysis.windows.net/powerbi/api"
Write-Host "Getting AAD Token for user: $UserName"
$token = Get-AADToken -username $UserName -Password $PassWord -clientId $ClientId -resource $ResourceUrl -Verbose

if($Action -eq "Workspace"){
    Write-Host "Creating a new Workspace"
    New-PowerBIWorkSpace -WorkspaceName $WorkspaceName -AccessToken $token
}elseif($action -eq "Publish"){
    Write-Host "Publishing PowerBI FIle: $FilePattern, in workspace: $WorkspaceName with user: $Username"
    Publish-PowerBIFile -WorkspaceName $WorkspaceName -Create $Create -AccessToken $token -FilePattern $FilePattern -Overwrite $Overwrite
}elseif($Action -eq "DeleteWorkspace"){
    Write-Host "Deleting a Workspace"
    Remove-PowerBIWorkSpace -WorkspaceName $WorkspaceName -AccessToken $token
}elseif($Action -eq "AddUsers"){
    Write-Host "Adding users to a Workspace"

    if($UserString -eq ""){
        Write-Warning "No users inserted in the variable!"
    }else{
        $users = $UserString.Split(",")
        Add-PowerBIWorkspaceUsers -WorkspaceName $WorkspaceName -Users $users -AccessToken $token -AccessRight $AccessRight -Create $Create
    }
}elseif($Action -eq "DataRefresh"){
    Write-Host "Trying to refresh Dataset"
    New-DatasetRefresh -WorkspaceName $WorkspaceName -DataSetName $Dataset -AccessToken $token
}elseif($Action -eq "UpdateDatasource"){
    Write-Host "Trying to update the datasource"

    if($UpdateAll -eq $false -and $Dataset -eq ""){
        Write-Error "When the update all function isn't checked you need to supply a dataset."
    }
    
    Update-PowerBIDatasetDatasources -WorkspaceName $WorkspaceName -OldUrl $OldUrl -NewUrl $NewUrl -DataSetName $Dataset -AccessToken $token -DatasourceType $DatasourceType -OldServer $OldServer -NewServer $NewServer -OldDatabase $OldDatabase -NewDatabase $NewDatabase -UpdateAll $UpdateAll
}
