[CmdletBinding()]
param()

#import powerbi module
Import-Module $PSScriptRoot\ps_modules\PowerBI

try {
    
    $userName = "nomulti@familie-vandergaag.nl"
    $filePattern = "D:\powerbi.pbix"
    $passWord = ConvertTo-SecureString -String "Ch@rl0tte" -AsPlainText -Force
    $clientId = "7b878115-55e1-48c5-bfb8-848dc07f9d1e"
    $groupName = "VSTS"
    $overwrite = $false
    $create = $true
    $users = ""
    $accesRight = ""
    $dataset = ""
    $action = "Publish"
    $oldServer = ""
    $newServer = ""
    $oldDatabase = ""
    $newDatabase = ""
    $datasourceType = ""
    $oldUrl = ""
    $newUrl =""

    .\run-task.ps1 -Username $userName -OldUrl $oldUrl -NewUrl $newUrl -OldServer $oldServer -DatasourceType $datasourceType -NewServer $newServer -OldDatabase $oldDatabase -NewDatabase $newDatabase -AccessRight $accesRight -Users $users -FilePattern $filePattern -Password $passWord -ClientId $clientId -WorkspaceName $groupName -Overwrite $overwrite -Create $create -Dataset $dataset -Action $action
}
finally {
    Write-Information "Done running the task"
}
