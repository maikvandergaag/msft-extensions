$powerBiBodyTemplate = @'
--{0}
Content-Disposition: form-data; name="fileData"; filename="{1}"
Content-Type: application/x-zip-compressed

{2}
--{0}--

'@

Function Set-PowerBIDataSetOwnership {
    Param(
        [parameter(Mandatory = $true)]$WorkspaceName,
        [parameter(Mandatory = $false)]$DataSetName,
        [parameter(Mandatory = $false)]$UpdateAll = $false
    )

    $GroupPath = Get-PowerBIGroupPath -WorkspaceName $WorkspaceName

    if ($GroupPath) {
        if ($UpdateAll) {
            $datasets = Get-PowerBiDataSets -GroupPath $groupPath
            foreach ($dataset in $datasets) {
                if ($dataset.name -eq $datasetName -and !$UpdateAll) {
                    $updateDataset = $true
                }

                if ($UpdateAll -or $updateDataset) {
                    if ($dataset) {
                        $setId = $dataset.id
                        $url = $powerbiUrl + "$GroupPath/datasets/$setId/Default.TakeOver"
                    }
                    else {
                        Write-Error "Dataset: Could not be found"
                    }
                
                    Invoke-API -Url $url -Method "Post" -Verbose
                }
            }
        }
    }    

    return $true
}

Function Update-PowerBIDatasetParameter {
    Param(
        [parameter(Mandatory = $true)]$Set,
        [parameter(Mandatory = $true)]$GroupPath,
        [parameter(Mandatory = $false)]$ParameterJSON
    )

    $setId = $Set.id
    $url = $powerbiUrl + "$GroupPath/datasets/$setId/Default.UpdateParameters"
    $itemValue = ConvertFrom-Json $ParameterJSON
    $newItemValue = ""

    $datasetParameters = Get-PowerBiParameters -GroupPath $GroupPath -SetId $setId
    foreach ($datasetParameter in $datasetParameters) {
        $datasetParameterName = $datasetParameter.name
  
        if ($itemValue.name -match $datasetParameterName) {       
            $newParameterValue = $itemValue | Where-Object name -eq $datasetParameterName
            $newParameterValue = $newParameterValue.newValue
            if ($newItemValue -eq "") {
                $newItemValue = "{
                                    'name': '$datasetParameterName',
                                    'newValue': '$newParameterValue'
                                }"
            }
            else {
                $newItemValue = $newItemValue + "," +
                "{
                        'name': '$datasetParameterName',
                        'newValue': '$newParameterValue'
                }"
            }
        }
    }

    if (!$newItemValue -eq "") {
        $body = "{ 
                    'updateDetails': [" + $newItemValue + "]
                }"
        Invoke-API -Url $url -Method "Post" -Body $body -ContentType "application/json"
    }
}

Function Update-PowerBIDatasetParameters {
    Param(
        [parameter(Mandatory = $true)]$WorkspaceName,
        [parameter(Mandatory = $false)]$datasetName,
        [parameter(Mandatory = $false)]$UpdateAll,
        [parameter(Mandatory = $false)]$UpdateValue
    )

    $groupPath = Get-PowerBIGroupPath -WorkspaceName $WorkspaceName
    if ($groupPath) {
        if ($UpdateAll) {
            $datasets = Get-PowerBiDataSets -GroupPath $groupPath
            foreach ($dataset in $datasets) {
                if ($dataset.name -eq $datasetName -and !$UpdateAll) {
                    $updateDataset = $true
                }

                if ($UpdateAll -or $updateDataset) {
                    Update-PowerBIDatasetParameter -GroupPath $groupPath -Set $dataset -ParameterJSON $UpdateValue
                }
            }
        }
    }
    else {
        Write-Error "Workspace: $WorkspaceName could not be found"
    }
}

Function Invoke-API {
    Param(
        [parameter(Mandatory = $true)][string]$Url,
        [parameter(Mandatory = $true)][string]$Method,
        [parameter(Mandatory = $false)][string]$Body,
        [parameter(Mandatory = $false)][string]$ContentType
    )

    $apiHeaders = Get-PowerBIAccessToken
    
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
        [parameter(Mandatory = $false)][string]$DataSetName,
        [parameter(Mandatory = $false)][string]$UpdateAll = $false
    )

    $groupPath = Get-PowerBIGroupPath -WorkspaceName $WorkspaceName
    if ($groupPath) {
        if ($UpdateAll) {
            $datasets = Get-PowerBiDataSets -GroupPath $groupPath
            foreach ($dataset in $datasets) {

                if ($dataset.name -eq $datasetName -and !$UpdateAll) {
                    $updateDataset = $true
                }

                if ($UpdateAll -or $updateDataset) {
                    if ($dataset) {

                        Write-Host "Processing dataset $($dataset.name)"
                        if ($dataset.isRefreshable -eq $true) {
                            $url = $powerbiUrl + $GroupPath + "/datasets/$($dataset.id)/refreshes"
                            Invoke-API -Url $url -Method "Post" -ContentType "application/json"
                        }
                        else {
                            Write-Warning "Dataset: $($dataset.name) cannot be refreshed!"
                        }


                    }
                }
            }
        }
    }
    else {
        Write-Error "Workspace: $WorkspaceName could not be found"
    }   
}

Function Get-PowerBIWorkspace {
    Param(
        [parameter(Mandatory = $true)][string]$WorkspaceName
    )

    $groupsUrl = $powerbiUrl + '/groups'
    $result = Invoke-API -Url $groupsUrl -Method "Get" -Verbose
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

    $groupPath = Get-PowerBIGroupPath -WorkspaceName $WorkspaceName
    if ($groupPath) {
        if ($UpdateAll) {
            $datasets = Get-PowerBiDataSets -GroupPath $groupPath

            foreach ($dataset in $datasets) {
                Update-PowerBIDatasetDatasource -GroupPath $groupPath -Set $dataset -OldUrl $OldUrl -NewUrl $NewUrl -DatasourceType $DatasourceType -OldServer $OldServer -NewServer $NewServer -OldDatabase $OldDatabase -NewDatabase $NewDatabase
            }
        }
        else {
            $dataset = Get-PowerBiDataSet -GroupPath $groupPath -Name $DatasetName

            if ($dataset) {
                Update-PowerBIDatasetDatasource -GroupPath $groupPath -Set $dataset -OldUrl $OldUrl -NewUrl $NewUrl -DatasourceType $DatasourceType -OldServer $OldServer -NewServer $NewServer -OldDatabase $OldDatabase -NewDatabase $NewDatabase
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

        Invoke-API -Url $url -Method "Post" -Body $body -ContentType "application/json"
    }
    else {
        Write-Error "Dataset: $DatasetName could not be found"
    }
}

Function Update-ConnectionStringDirectQuery {
    Param(
        [parameter(Mandatory = $true)]$WorkspaceName,
        [parameter(Mandatory = $true)]$DatasetName,
        [parameter(Mandatory = $true)]$ConnectionString
    )

    $groupPath = Get-PowerBIGroupPath -WorkspaceName $WorkspaceName 
    $set = Get-PowerBIDataSet -GroupPath $groupPath -Name $DatasetName 
    $setId = $set.id

    $body = @{
        connectionString = $ConnectionString
    } | ConvertTo-Json
    
    $url = $powerbiUrl + "$groupPath/datasets/$setId/Default.SetAllConnections"
     
    Invoke-API -Url $url -Method "Post" -Body $body -ContentType "application/json"
}

Function Get-PowerBIReport {
    Param(
        [parameter(Mandatory = $true)]$GroupPath,
        [parameter(Mandatory = $true)]$ReportName
    )

    $url = $powerbiUrl + $GroupPath + "/reports"

    $result = Invoke-API -Url $url -Method "Get" -Verbose
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
        [parameter(Mandatory = $true)]$Name
    )
    
    $url = $powerbiUrl + "$GroupPath/datasets"
    $result = Invoke-API -Url $url -Method "Get" -Verbose
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
        [parameter(Mandatory = $true)]$GroupPath
    )
    
    $url = $powerbiUrl + "$GroupPath/datasets"
    $result = Invoke-API -Url $url -Method "Get" -Verbose
    $sets = $result.value

    return $sets
}

Function Get-PowerBiParameters {
    Param(
        [parameter(Mandatory = $true)]$GroupPath,
        [parameter(Mandatory = $true)]$SetId
    )
    
    $url = $powerbiUrl + "$GroupPath/datasets/$SetId/parameters"
    $result = Invoke-API -Url $url -Method "Get" -Verbose
    $parameters = $result.value

    return $parameters
}

Function New-PowerBIWorkSpace {
    Param(
        [parameter(Mandatory = $true)]$WorkspaceName
    )

    $workspace = Get-PowerBIWorkspace -WorkspaceName $WorkspaceName -Verbose

    if ($workspace) {
        Write-Host "Workspace: $WorkspaceName already exists"
    }
    else {
        Write-Host "Trying to create workspace: $WorkspaceName"
        $url = $powerbiUrl + "/groups"

        $body = @{
            name = $WorkspaceName
        } | ConvertTo-Json
    
        $result = Invoke-API -Url $url -Method "Post" -Body $body -ContentType "application/json"
        
        Write-Host "Workspace: $WorkspaceName created!"
        Write-Output $result
    }
}

Function Remove-PowerBIWorkSpace {
    Param(
        [parameter(Mandatory = $true)]$WorkspaceName
    )
 
    $workspace = Get-PowerBIWorkspace -WorkspaceName $WorkspaceName -Verbose
 
    if ($workspace) {
        Write-Host "Workspace: $WorkspaceName exists"
        $groupPath = Get-PowerBIGroupPath -WorkspaceName $WorkspaceName
        $url = $powerbiUrl + $groupPath
        Invoke-API -Url $url -Method "Delete" -Verbose
    }
    else {
        Write-Host "Workspace: $WorkspaceName does exist"
    }
}

Function Import-PowerBIFile {
    Param(
        [parameter(Mandatory = $true)]$GroupPath,
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
 
    $result = Invoke-API -Url $url -Method "Post" -Body $body -ContentType "multipart/form-data; boundary=--$boundary" 

    $reportId = $result.Id
    Write-Host "##vso[task.setvariable variable=PowerBIActions.ReportId]$reportId"

    return $result
}
Function Get-PowerBIGroupPath {
    Param(
        [parameter(Mandatory = $true)]$WorkspaceName,
        [parameter()][bool]$Create = $false
    )
    $groupsPath = ""
    if ($WorkspaceName -eq "me") {
        $groupsPath = "/"
    }
    else {
        Write-Host "Getting Power BI Workspace properties; $WorkspaceName"
        $workspace = Get-PowerBIWorkspace -WorkspaceName $WorkspaceName -Verbose

        if ($Create -And !$workspace) {
            $workspace = New-PowerBIWorkSpace -WorkspaceName $WorkspaceName
        }
        elseif (!$workspace) {
            Throw "Power BI Workspace: $WorkspaceName does not exist"
        }
        $groupId = $workspace.Id

        #writing Workspace Id
        Write-Host "##vso[task.setvariable variable=PowerBIActions.WorkspaceId]$groupId"

        $groupsPath = "/groups/$groupId"
    }

    return $groupsPath
}

Function Add-PowerBIWorkspaceUsers {
    Param(
        [parameter(Mandatory = $true)]$WorkspaceName,
        [parameter()][bool]$Create = $false,
        [parameter(Mandatory = $true)]$Users,
        [parameter(Mandatory = $true)][ValidateSet("Admin", "Contributor", "Member", "Viewer", IgnoreCase = $false)]$AccessRight = "Admin"	
    )
    $GroupPath = Get-PowerBIGroupPath -WorkspaceName $WorkspaceName -Create $Create
    $url = $powerbiUrl + $GroupPath + "/users"

    foreach ($user in $Users) {
        $body = @{
            groupUserAccessRight = $AccessRight
            emailAddress         = $user
        } | ConvertTo-Json	

        Invoke-API -Url $url -Method "Post" -Body $body -ContentType "application/json" 
    }
}

Function Add-PowerBIWorkspaceGroup {
    Param(
        [parameter(Mandatory = $true)]$WorkspaceName,
        [parameter()][bool]$Create = $false,
        [parameter(Mandatory = $true)]$Groups,
        [parameter(Mandatory = $true)][ValidateSet("Admin", "Contributor", "Member", "Viewer", IgnoreCase = $false)]$AccessRight = "Admin"	
    )
    $GroupPath = Get-PowerBIGroupPath -WorkspaceName $WorkspaceName -Create $Create
    $url = $powerbiUrl + $GroupPath + "/users"

    foreach ($group in $Groups) {
        $body = @{
            groupUserAccessRight = $AccessRight
            identifier           = $group
            principalType        = "Group"
        } | ConvertTo-Json	

        Invoke-API -Url $url -Method "Post" -Body $body -ContentType "application/json" 
    }
}

Function Add-PowerBIWorkspaceSP {
    Param(
        [parameter(Mandatory = $true)]$WorkspaceName,
        [parameter()][bool]$Create = $false,
        [parameter(Mandatory = $true)]$Sps,
        [parameter(Mandatory = $true)][ValidateSet("Admin", "Contributor", "Member", "Viewer", IgnoreCase = $false)]$AccessRight = "Admin"	
    )
    $GroupPath = Get-PowerBIGroupPath -WorkspaceName $WorkspaceName -Create $Create
    $url = $powerbiUrl + $GroupPath + "/users"

    foreach ($sp in $Sps) {
        $body = @{
            groupUserAccessRight = $AccessRight
            identifier           = $sp
            principalType        = "App"

        } | ConvertTo-Json	

        Invoke-API -Url $url -Method "Post" -Body $body -ContentType "application/json" 
    }
}

Function Publish-PowerBIFile {
    Param(
        [parameter(Mandatory = $true)]$WorkspaceName,
        [parameter(Mandatory = $true)]$FilePattern,
        [parameter()][bool]$Create = $false,
        [parameter()][bool]$Overwrite = $false
    )

    $GroupPath = Get-PowerBIGroupPath -WorkspaceName $WorkspaceName -Create $Create
    
    $searchedFiles = Get-ChildItem $filePattern

    foreach ($foundFile in $searchedFiles) {
        $directory = $foundFile.DirectoryName
        $file = $foundFile.Name
    
        $filePath = "$directory\$file"
        Write-Host "Trying to publish PowerBI File: $FilePath"
    
        #Check for exisiting report
        $fileNamewithoutextension = [IO.Path]::GetFileNameWithoutExtension($filePath)
        Write-Host "Checking for existing Reports with the name: $fileNamewithoutextension"
    
        $report = Get-PowerBIReport -GroupPath $GroupPath -ReportName $fileNamewithoutextension -Verbose
        
        $publish = $true
        $nameConflict = "Abort"
        if ($report) {
            Write-Verbose "Reports exists"
            if ($Overwrite) {
                Write-Verbose "Reports exists and needs to be overwritten"
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
            Import-PowerBiFile -GroupPath $GroupPath -Path $FilePath -Conflict $nameConflict -Verbose
        }
    }
}

Export-ModuleMember -Function "*-*" 
