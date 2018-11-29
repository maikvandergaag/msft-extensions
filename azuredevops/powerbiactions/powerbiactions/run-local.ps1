[CmdletBinding()]
param()

#import powerbi module
Import-Module $PSScriptRoot\ps_modules\PowerBI

try {
    
    $userName = "nomulti@familie-vandergaag.nl"
    $filePattern = "D:\test.pbix"
    $passWord = ConvertTo-SecureString -String "Ch@rl0tte" -AsPlainText -Force
    $clientId = "7b878115-55e1-48c5-bfb8-848dc07f9d1e"
    $groupName = "Extension"
    $overwrite = $true
    $create = $true
    $users = "maik@familie-vandergaag.nl,peter@familie-vandergaag.nl"
    $accesRight = "Admin"
    $dataset = "test"
    $action = "DataRefresh"
    $connectionstring = "data source=MyAzureDB.database.windows.net;initial catalog=Sample2;persist security info=True;encrypt=True;trustservercertificate=Fals"

    .\run-task.ps1 -Username $userName -AccessRight $accesRight -Users $users -FilePattern $filePattern -Password $passWord -ClientId $clientId -WorkspaceName $groupName -Overwrite $overwrite -Connectionstring $connectionstring -Create $create -Dataset $dataset -Action $action
}
finally {
    Write-Information "Done running the task"
}