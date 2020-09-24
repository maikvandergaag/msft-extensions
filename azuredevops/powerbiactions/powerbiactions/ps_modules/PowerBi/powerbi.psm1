$powerbiUrl = "https://api.powerbi.com/v1.0"

$powerBiBodyTemplate = @'
--{0}
Content-Disposition: form-data; name="fileData"; filename="{1}"
Content-Type: application/x-zip-compressed
{2}
--{0}--
'@

<#
    Clear-Host
    #--------------------------------------- Get Token using SPN Authentication ---------------------------------------------------#
    $applicationId = "" #Enter the Application (Client) ID here
    $clientSecret = "" | ConvertTo-SecureString -AsPlainText -Force #Enter the Application (Client) Secret here
    $TenantId = "" #Enter the Tenant ID here

    #Generate Credential usign Client ID & Secret
    $pscredential = New-Object -TypeName System.Management.Automation.PSCredential($applicationId, $clientSecret)
    #Log into PowerBI Service using the Credentials
    Connect-PowerBIServiceAccount -ServicePrincipal -Credential $pscredential -Tenant $TenantId
    #Collect the Access Token
    $AccessToken = Get-PowerBIAccessToken -AsString
    $AccessToken = $AccessToken.Replace('Bearer ','')
    #echo $AccessToken #Print the Access Token
#>

Function Invoke-API {
    Param(
        [parameter(Mandatory = $true)][string]$Url,
        [parameter(Mandatory = $true)][string]$Method,
        [parameter(Mandatory = $true)]$AccessToken,
        [parameter(Mandatory = $false)][string]$Body,
        [parameter(Mandatory = $false)][string]$ContentType
    )

    $apiHeaders = @{
        'Content-Type'  = 'application/json'
        'Authorization' = "Bearer $AccessToken"
    }

    Write-Verbose "Trying to invoke api: $Url"

    try {
        if ($Body) {
            $result = Invoke-RestMethod -Uri $Url -Headers $apiHeaders -Method $Method -ContentType $ContentType -Body $Body
        }
        else {
            $result = Invoke-RestMethod -Uri $Url -Headers $apiHeaders -Method $Method
        }
    }
    catch [System.Net.WebException] {
        $ex = $_.Exception
        try {
            if ($null -ne $ex.Response) {
                $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
                $errorContent = $streamReader.ReadToEnd() | ConvertFrom-Json
                
                if ($errorContent.error.code -eq "AddingAlreadyExistsGroupUserNotSupportedError") {
                    $existUser = $true
                }
            }

            if ($existUser) {
                Write-Warning "User already exists. Updating an existing user is not supported"
            }
            else {
                $message = $errorContent.error.message
                if ($message) {
                    Write-Error $message
                }
                else {
                    Write-Error -Exception $ex
                }               
            }
        }
        catch {
            throw;
        }
        finally {
            if ($reader) { $reader.Dispose() }
            if ($stream) { $stream.Dispose() }
        }       		
    }

    return $result
}

Function New-DatasetRefresh {
    Param(
        [parameter(Mandatory = $true)][string]$WorkspaceName,
        [parameter(Mandatory = $true)][string]$DataSetName,
        [parameter(Mandatory = $true)]$AccessToken
    )
    
    $GroupPath = Get-PowerBIGroupPath -WorkspaceName $WorkspaceName -AccessToken $AccessToken
    $set = Get-PowerBIDataSet -GroupPath $GroupPath -AccessToken $AccessToken -Name $DatasetName

    if ($set) {
        $url = $powerbiUrl + $GroupPath + "/datasets/$($set.id)/refreshes"
        Invoke-API -Url $url -Method "Post" -ContentType "application/json" -AccessToken $AccessToken
    }
    else {
        Write-Warning "The dataset: $DataSetName does not exist."
    }
    
}
Function Get-PowerBIWorkspace {
    Param(
        [parameter(Mandatory = $true)][string]$WorkspaceName,
        [parameter(Mandatory = $true)]$AccessToken
    )

    $groupsUrl = $powerbiUrl + '/myorg/groups'
    $result = Invoke-API -Url $groupsUrl -Method "Get" -AccessToken $AccessToken -Verbose
    $groups = $result.value

    $workspace = $null;
    if (-not [string]::IsNullOrEmpty($WorkspaceName)) {

        Write-Verbose "Trying to find workspace: $WorkspaceName"		
        $groups = @($groups | Where-Object name -eq $WorkspaceName)
    
        if ($groups.Count -ne 0) {
            $workspace = $groups[0]		
        }				
    }

    return $workspace
}

Function Update-PowerBIDatasetDatasources {
    Param(
        [parameter(Mandatory = $true)]$WorkspaceName,
        [parameter(Mandatory = $true)]$AccessToken,
        [parameter(Mandatory = $false)]$DatasetName,
        [parameter(Mandatory = $true)]$DatasourceType,
        [parameter(Mandatory = $false)]$OldServer,
        [parameter(Mandatory = $false)]$NewServer,
        [parameter(Mandatory = $false)]$OldDatabase,
        [parameter(Mandatory = $false)]$NewDatabase,
        [parameter(Mandatory = $false)]$OldUrl,
        [parameter(Mandatory = $false)]$NewUrl,
        [parameter(Mandatory = $false)]$UpdateAll
    )

    $groupPath = Get-PowerBIGroupPath -WorkspaceName $WorkspaceName -AccessToken $AccessToken
    if ($groupPath) {
        if ($UpdateAll) {
            $datasets = Get-PowerBiDataSets -GroupPath $groupPath -AccessToken $AccessToken

            foreach ($dataset in $datasets) {
                Update-PowerBIDatasetDatasource -GroupPath $groupPath -Set $dataset -OldUrl $OldUrl -NewUrl $NewUrl -AccessToken $AccessToken -DatasourceType $DatasourceType -OldServer $OldServer -NewServer $NewServer -OldDatabase $OldDatabase -NewDatabase $NewDatabase
            }
        }
        else {
            $dataset = Get-PowerBiDataSet -GroupPath $groupPath -AccessToken $AccessToken -Name $DatasetName

            if ($dataset) {
                Update-PowerBIDatasetDatasource -GroupPath $groupPath -Set $dataset -OldUrl $OldUrl -NewUrl $NewUrl -AccessToken $AccessToken -DatasourceType $DatasourceType -OldServer $OldServer -NewServer $NewServer -OldDatabase $OldDatabase -NewDatabase $NewDatabase
            }
            else {
                Write-Warning "Dataset $DatasetName could not be found"
            }
        }
    }
    else {
        Write-Error "Workspace: $WorkspaceName could not be found"
    }
}

Function Update-PowerBIDatasetDatasource {
    Param(
        [parameter(Mandatory = $true)]$Set,
        [parameter(Mandatory = $true)]$GroupPath,
        [parameter(Mandatory = $true)]$DatasourceType,
        [parameter(Mandatory = $true)]$AccessToken,
        [parameter(Mandatory = $false)]$OldServer,
        [parameter(Mandatory = $false)]$NewServer,
        [parameter(Mandatory = $false)]$OldDatabase,
        [parameter(Mandatory = $false)]$NewDatabase,
        [parameter(Mandatory = $false)]$OldUrl,
        [parameter(Mandatory = $false)]$NewUrl
    )

    if ($set) {
        $setId = $dataset.id
        $url = $powerbiUrl + "$GroupPath/datasets/$setId/Default.UpdateDatasources"

        if ($DatasourceType -eq "OData" -OR $DatasourceType -eq "SharePointList" -OR $DatasourceType -eq "SharePointFolder") {
            $body = "{ 
                    'updateDetails': [{
                        'datasourceSelector': {
                            'datasourceType': '$DatasourceType',
                            'connectionDetails': {
                            'url': '$OldUrl'
                            }
                        },
                        'connectionDetails': {
                            'url': '$NewUrl'
                        }
                        }]
                  }"
        }
        else {
            $body = "{ 
                'updateDetails': [{
                    'datasourceSelector': {
                        'datasourceType': '$DatasourceType',
                        'connectionDetails': {
                        'server': '$OldServer',
                        'database': '$OldDatabase'
                        }
                    },
                    'connectionDetails': {
                        'server': '$NewServer',
                        'database': '$NewDatabase'
                    }
                    }]
              }"
        }

        Invoke-API -Url $url -Method "Post" -AccessToken $AccessToken -Body $body -ContentType "application/json"
    }
    else {
        Write-Error "Dataset: $DatasetName could not be found"
    }
}

Function Update-ConnectionStringDirectQuery {
    Param(
        [parameter(Mandatory = $true)]$WorkspaceName,
        [parameter(Mandatory = $true)]$AccessToken,
        [parameter(Mandatory = $true)]$DatasetName,
        [parameter(Mandatory = $true)]$ConnectionString
    )

    $groupPath = Get-PowerBIGroupPath -WorkspaceName $WorkspaceName -AccessToken $AccessToken

    $set = Get-PowerBIDataSet -GroupPath $groupPath -AccessToken $AccessToken -Name $DatasetName 
    $setId = $set.id

    $body = @{
        connectionString = $ConnectionString
    } | ConvertTo-Json
    
    $url = $powerbiUrl + "$groupPath/datasets/$setId/Default.SetAllConnections"
     
    Invoke-API -Url $url -Method "Post" -AccessToken $AccessToken -Body $body -ContentType "application/json"
}

Function Get-PowerBIReport {
    Param(
        [parameter(Mandatory = $true)]$GroupPath,
        [parameter(Mandatory = $true)]$AccessToken,
        [parameter(Mandatory = $true)]$ReportName
    )

    $url = $powerbiUrl + $GroupPath + "/reports"

    $result = Invoke-API -Url $url -Method "Get" -AccessToken $AccessToken -Verbose
    $reports = $result.value
	
    $report	= $null;
    if (-not [string]::IsNullOrEmpty($ReportName)) {
        Write-Verbose "Trying to find report '$ReportName'"		

        $reports = @($reports | Where-Object name -eq $ReportName)
        if ($reports.Count -ne 0) {
            $report = $reports[0]		
        }			
    }	

    return $report
}

Function Get-PowerBiDataSet {
    Param(
        [parameter(Mandatory = $true)]$GroupPath,
        [parameter(Mandatory = $true)]$AccessToken,
        [parameter(Mandatory = $true)]$Name
    )
    
    $url = $powerbiUrl + "$GroupPath/datasets"
    $result = Invoke-API -Url $url -Method "Get" -AccessToken $AccessToken -Verbose
    $sets = $result.value
	
    $set = $null;
    if (-not [string]::IsNullOrEmpty($Name)) {
        Write-Verbose "Trying to find dataset '$Name'"		

        $sets = @($sets | Where-Object name -eq $Name)
        if ($sets.Count -ne 0) {
            $set = $sets[0]		
        }			
    }	

    return $set
}

Function Get-PowerBiDataSets {
    Param(
        [parameter(Mandatory = $true)]$GroupPath,
        [parameter(Mandatory = $true)]$AccessToken
    )
    
    $url = $powerbiUrl + "$GroupPath/datasets"
    $result = Invoke-API -Url $url -Method "Get" -AccessToken $AccessToken -Verbose
    $sets = $result.value

    return $sets
}

Function New-PowerBIWorkSpace {
    Param(
        [parameter(Mandatory = $true)]$WorkspaceName,
        [parameter(Mandatory = $true)]$AccessToken
    )

    $workspace = Get-PowerBIWorkspace -WorkspaceName $WorkspaceName -AccessToken $AccessToken -Verbose

    if ($workspace) {
        Write-Host "Workspace: $WorkspaceName already exists"
    }
    else {
        Write-Host "Trying to create workspace: $WorkspaceName"
        $url = $powerbiUrl + "/myorg/groups"

        $body = @{
            name = $WorkspaceName
        } | ConvertTo-Json
    
        $result = Invoke-API -Url $url -Method "Post" -AccessToken $AccessToken -Body $body -ContentType "application/json"
        
        Write-Host "Workspace: $WorkspaceName created!"
        Write-Output $result
    }
}

Function Remove-PowerBIWorkSpace {
    Param(
        [parameter(Mandatory = $true)]$WorkspaceName,
        [parameter(Mandatory = $true)]$AccessToken
    )
 
    $workspace = Get-PowerBIWorkspace -WorkspaceName $WorkspaceName -AccessToken $AccessToken -Verbose
 
    if ($workspace) {
        Write-Host "Workspace: $WorkspaceName exists"
        $groupPath = Get-PowerBIGroupPath -WorkspaceName $WorkspaceName -AccessToken $AccessToken
        $url = $powerbiUrl + $groupPath
        Invoke-API -Url $url -Method "Delete" -AccessToken $AccessToken -Verbose
    }
    else {
        Write-Host "Workspace: $WorkspaceName does exist"
    }
}

Function Import-PowerBIFile {
    Param(
        [parameter(Mandatory = $true)]$GroupPath,
        [parameter(Mandatory = $true)]$AccessToken,
        [parameter(Mandatory = $true)]$Conflict,
        [parameter(Mandatory = $true)]$Path
    )

    $fileName = [IO.Path]::GetFileName($Path)
    $boundary = [guid]::NewGuid().ToString()
    $fileBytes = [System.IO.File]::ReadAllBytes($Path)
    $encoding = [System.Text.Encoding]::GetEncoding("iso-8859-1")
    $encodedFileName = [System.Web.HttpUtility]::UrlEncode($fileName) 
    $url = $powerbiUrl + "$GroupPath/imports?datasetDisplayName=$encodedFileName&nameConflict=$Conflict"

    $body = $powerBiBodyTemplate -f $boundary, $fileName, $encoding.GetString($fileBytes)
 
    $result = Invoke-API -Url $url -Method "Post" -AccessToken $AccessToken -Body $body -ContentType "multipart/form-data; boundary=--$boundary" 

    $reportId = $result.Id
    Write-Host "##vso[task.setvariable variable=PowerBIActions.ReportId]$reportId"

    return $result
}
Function Get-PowerBIGroupPath {
    Param(
        [parameter(Mandatory = $true)]$WorkspaceName,
        [parameter(Mandatory = $true)]$AccessToken,
        [parameter()][bool]$Create = $false
    )
    $groupsPath = ""
    if ($WorkspaceName -eq "me") {
        $groupsPath = "/myorg"
    }
    else {
        Write-Host "Getting Power BI Workspace properties; $WorkspaceName"
        $workspace = Get-PowerBIWorkspace -WorkspaceName $WorkspaceName -AccessToken $AccessToken -Verbose

        if ($Create -And !$workspace) {
            $workspace = New-PowerBIWorkSpace -WorkspaceName $WorkspaceName -AccessToken $AccessToken
        }
        elseif (!$workspace) {
            Throw "Power BI Workspace: $WorkspaceName does not exist"
        }
        $groupId = $workspace.Id

        #writing Workspace Id
        Write-Host "##vso[task.setvariable variable=PowerBIActions.WorkspaceId]$groupId"

        $groupsPath = "/myorg/groups/$groupId"
    }

    return $groupsPath
}
Function Take-PowerBIDataSetInGroup {
    Param(
        [parameter(Mandatory = $true)]$GroupPath,
        [parameter(Mandatory = $true)]$AccessToken,
        [parameter(Mandatory = $true)]$Set
    )

    if ($Set) {
        $setId = $dataset.id
        $url = $powerbiUrl + "$GroupPath/datasets/$setId/Default.TakeOver"
    }
    else {
        Write-Error "Dataset: Could not be found"
    }
    
    Invoke-API -Url $url -Method "Post" -AccessToken $AccessToken -Verbose
    
    return $true
}
Function Add-PowerBIWorkspaceUsers {
    Param(
        [parameter(Mandatory = $true)]$WorkspaceName,
        [parameter()][bool]$Create = $false,
        [parameter(Mandatory = $true)]$AccessToken,
        [parameter(Mandatory = $true)]$Users,
        [parameter(Mandatory = $true)][ValidateSet("Admin", "Contributor", "Member", "Viewer", IgnoreCase = $false)]$AccessRight = "Admin"	
    )
    $GroupPath = Get-PowerBIGroupPath -WorkspaceName $WorkspaceName -AccessToken $AccessToken -Create $Create
    $url = $powerbiUrl + $GroupPath + "/users"

    foreach ($user in $Users) {
        $body = @{
            groupUserAccessRight = $AccessRight
            emailAddress         = $user
        } | ConvertTo-Json	

        Invoke-API -Url $url -Method "Post" -AccessToken $AccessToken -Body $body -ContentType "application/json" 
    }
}

Function Get-PowerBiDataSetParameter {
    Param(
        [parameter(Mandatory = $true)]$GroupPath,
        [parameter(Mandatory = $true)]$AccessToken,
        [parameter(Mandatory = $true)]$setId,
        [parameter(Mandatory = $true)]$Environment,
        [parameter(Mandatory = $true)]$configFilePath
    )
    
    $url = $powerbiUrl + "$GroupPath/datasets/$setId/parameters"
    $updateJSON = ""

    $config_PowerBI_JSON = Get-Content $configFilePath | ConvertFrom-Json
    $JSON_ParametersPBI = $config_PowerBI_JSON.Environment.$Environment

    $result = Invoke-API -Url $url -Method "Get" -AccessToken $AccessToken -Verbose
    $parameters = $result.value
	
    foreach ($parameter in $parameters) {
        $parameterName = $parameter.name
        if ($JSON_ParametersPBI.name -match $parameterName) {       
            $parameterValue = $JSON_ParametersPBI | Where-Object name -eq $parameterName
            $parameterValue = $parameterValue.newValue
            if ($updateJSON -eq "") {
                $updateJSON = "{
                                    'name': '$parameterName',
                                    'newValue': '$parameterValue'
                                }"
            }
            else {
                $updateJSON = $updateJSON + "," +
                "{
                        'name': '$parameterName',
                        'newValue': '$parameterValue'
                }"
            }
        }
    }

    if (!$updateJSON -eq "") {
        $updateJSON = "{ 
                            'updateDetails': [" + $updateJSON + "]
                       }"
    }
    return $updateJSON
}
Function Update-PowerBIDatasetParameter {
    Param(
        [parameter(Mandatory = $true)]$Set,
        [parameter(Mandatory = $true)]$GroupPath,
        [parameter(Mandatory = $true)]$DatasourceType,
        [parameter(Mandatory = $true)]$AccessToken,
        [parameter(Mandatory = $false)]$ParameterJSON
    )

    if ($set) {
        $success = Take-PowerBIDataSetInGroup -Set $set -GroupPath $groupPath -AccessToken $AccessToken
        if ($success) {
            $setId = $dataset.id
            $url = $powerbiUrl + "$GroupPath/datasets/$setId/Default.UpdateParameters"
            $body = $ParameterJSON

            Invoke-API -Url $url -Method "Post" -AccessToken $AccessToken -Body $body -ContentType "application/json"
        }
    }
    else {
        Write-Error "Dataset: $DatasetName could not be found"
    }
}
Function Update-PowerBIDatasetParameters {
    Param(
        [parameter(Mandatory = $true)]$WorkspaceName,
        [parameter(Mandatory = $true)]$AccessToken,
        [parameter(Mandatory = $false)]$DatasetName,
        [parameter(Mandatory = $true)]$DatasourceType,
        [parameter(Mandatory = $false)]$UpdateAll
    )

    $groupPath = Get-PowerBIGroupPath -WorkspaceName $WorkspaceName -AccessToken $AccessToken
    if ($groupPath) {
        if ($UpdateAll) {
            $datasets = Get-PowerBiDataSets -GroupPath $groupPath -AccessToken $AccessToken
            foreach ($dataset in $datasets) {
                $updateJSON = Get-PowerBiDataSetParameter -GroupPath $GroupPath -AccessToken $AccessToken -setId $dataset.id -Environment $Environment -configFilePath $configFilePath
                if (!$updateJSON -eq "") {
                    Update-PowerBIDatasetParameter -GroupPath $groupPath -DatasourceType $DatasourceType -AccessToken $AccessToken -Set $dataset -ParameterJSON $updateJSON
                }
            }
        }
    }
    else {
        Write-Error "Workspace: $WorkspaceName could not be found"
    }
}
Function Add-PowerBIWorkspaceGroup {
    Param(
        [parameter(Mandatory = $true)]$WorkspaceName,
        [parameter()][bool]$Create = $false,
        [parameter(Mandatory = $true)]$AccessToken,
        [parameter(Mandatory = $true)]$Groups,
        [parameter(Mandatory = $true)][ValidateSet("Admin", "Contributor", "Member", "Viewer", IgnoreCase = $false)]$AccessRight = "Admin"	
    )
    $GroupPath = Get-PowerBIGroupPath -WorkspaceName $WorkspaceName -AccessToken $AccessToken -Create $Create
    $url = $powerbiUrl + $GroupPath + "/users"

    foreach ($group in $Groups) {
        $body = @{
            groupUserAccessRight = $AccessRight
            identifier           = $group
            principalType        = "Group"
        } | ConvertTo-Json	

        Invoke-API -Url $url -Method "Post" -AccessToken $AccessToken -Body $body -ContentType "application/json" 
    }
}

Function Add-PowerBIWorkspaceSP {
    Param(
        [parameter(Mandatory = $true)]$WorkspaceName,
        [parameter()][bool]$Create = $false,
        [parameter(Mandatory = $true)]$AccessToken,
        [parameter(Mandatory = $true)]$Sps,
        [parameter(Mandatory = $true)][ValidateSet("Admin", "Contributor", "Member", "Viewer", IgnoreCase = $false)]$AccessRight = "Admin"	
    )
    $GroupPath = Get-PowerBIGroupPath -WorkspaceName $WorkspaceName -AccessToken $AccessToken -Create $Create
    $url = $powerbiUrl + $GroupPath + "/users"

    foreach ($sp in $Sps) {
        $body = @{
            groupUserAccessRight = $AccessRight
            identifier           = $sp
            principalType        = "App"

        } | ConvertTo-Json	

        Invoke-API -Url $url -Method "Post" -AccessToken $AccessToken -Body $body -ContentType "application/json" 
    }
}

Function Publish-PowerBIFile {
    Param(
        [parameter(Mandatory = $true)]$WorkspaceName,
        [parameter(Mandatory = $true)]$FilePattern,
        [parameter()][bool]$Create = $false,
        [parameter()][bool]$Overwrite = $false,
        [parameter(Mandatory = $true)]$AccessToken
    )

    $GroupPath = Get-PowerBIGroupPath -WorkspaceName $WorkspaceName -AccessToken $AccessToken -Create $Create
    
    $searchedFiles = Get-ChildItem $filePattern
    foreach ($foundFile in $searchedFiles) {
        $directory = $foundFile.DirectoryName
        $file = $foundFile.Name
    
        $filePath = "$directory\$file"
        Write-Host "Trying to publish PowerBI File: $FilePath"
    
        #Check for exisiting report
        $fileNamewithoutextension = [IO.Path]::GetFileNameWithoutExtension($filePath)
        Write-Host "Checking for existing Reports with the name: $fileNamewithoutextension"
    
        $report = Get-PowerBIReport -GroupPath $GroupPath -AccessToken $AccessToken -ReportName $fileNamewithoutextension -Verbose
        
        $publish = $true
        $nameConflict = "Abort"
        if ($report) {
            Write-Verbose "Reports exisits"
            if ($Overwrite) {
                Write-Verbose "Reports exisits and needs to be overwritten"
                $nameConflict = "Overwrite"
            }
            else {
                $publish = $false
                Write-Warning "Report already exists"
            }
        }
       
        if ($publish) {
            #Import PowerBi file
            Write-Host "Importing PowerBI File"
            Import-PowerBiFile -GroupPath $GroupPath -AccessToken $AccessToken -Path $FilePath -Conflict $nameConflict -Verbose
        }
    }
}

Export-ModuleMember -Function "*-*"
Export-ModuleMember -Variable "powerbiUrl"