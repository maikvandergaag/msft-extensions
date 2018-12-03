[CmdletBinding()]
param()

#import powerbi module
Import-Module $PSScriptRoot\ps_modules\PowerBI

try {
    
    $userName = "nomulti@familie-vandergaag.nl"
    $filePattern = "D:\powerbi-analysys.pbix"
    $passWord = 
    $clientId = "7b878115-55e1-48c5-bfb8-848dc07f9d1e"
    $groupName = "PowerBI"
    $overwrite = $true
    $create = $true
    $users = "maik@familie-vandergaag.nl,peter@familie-vandergaag.nl"
    $accesRight = "Admin"
    $dataset = "PowerBI"
    $action = "UpdateDatasource"
    $oldServer = "powerbisql55.database.windows.net"
    $newServer = "powerbisql55.database.windows.net"
    $oldDatabase = "sql01"
    $newDatabase = "sql02"
    $datasourceType = "Sql"
    $oldUrl = ""
    $newUrl =""

    .\run-task.ps1 -Username $userName -OldUrl $oldUrl -NewUrl $newUrl -OldServer $oldServer -DatasourceType $datasourceType -NewServer $newServer -OldDatabase $oldDatabase -NewDatabase $newDatabase -AccessRight $accesRight -Users $users -FilePattern $filePattern -Password $passWord -ClientId $clientId -WorkspaceName $groupName -Overwrite $overwrite -Create $create -Dataset $dataset -Action $action
}
finally {
    Write-Information "Done running the task"
}
