[CmdletBinding()]
param()

#import powerbi module
Import-Module $PSScriptRoot\ps_modules\PowerBI
Import-Module $PSScriptRoot\ps_modules\ADAL.PS

try {
    
    $userName = "nomulti@familie-vandergaag.nl"
    $filePattern = "D:\test.pbix"
    $passWord = ConvertTo-SecureString -String "" -AsPlainText -Force
    $clientId = "7b878115-55e1-48c5-bfb8-848dc07f9d1e"#"7b878115-55e1-48c5-bfb8-848dc07f9d1e"
    $clientSecret = ConvertTo-SecureString -String "test" -AsPlainText -Force
    $groupName = "New Workspace"
    $overwrite = $true
    $create = $true
    $users = "maik@familie-vandergaag.nl"
    $accesRight = "Admin"
    $dataset = "powerbi"
    $action = "Publish"
    $oldServer = "powerbisql55.database.windows.net"
    $newServer = "powerbisql55.database.windows.net"
    $oldDatabase = "sql01"
    $newDatabase = "sql02"
    $datasourceType = "Sql"
    $oldUrl = ""
    $newUrl =""
    $UpdateAll = $false
    $TenantId = ""

    .\run-task.ps1 -Username $userName -OldUrl $oldUrl -NewUrl $newUrl -OldServer $oldServer -DatasourceType $datasourceType -NewServer $newServer -OldDatabase $oldDatabase -NewDatabase $newDatabase -AccessRight $accesRight -Users $users -FilePattern $filePattern -Password $passWord -ClientId $clientId -WorkspaceName $groupName -Overwrite $overwrite -Create $create -Dataset $dataset -Action $action -UpdateAll $UpdateAll -ClientSecret $clientSecret -TenantId $TenantId 
}
finally {
    Write-Information "Done running the task"
}
