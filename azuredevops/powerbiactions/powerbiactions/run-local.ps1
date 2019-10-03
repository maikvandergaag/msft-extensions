[CmdletBinding()]
param()

#import powerbi module
Import-Module $PSScriptRoot\ps_modules\PowerBI
Import-Module $PSScriptRoot\ps_modules\ADAL.PS

try {
    
    $userName = "nomulti@familie-vandergaag.nl"
    $filePattern = "D:\test.pbix"
    $passWord = ConvertTo-SecureString -String "Tibbe11711" -AsPlainText -Force
    $clientId = "c8e611b9-4c16-4e8a-80a0-40123a91ac52"#"7b878115-55e1-48c5-bfb8-848dc07f9d1e"
    $clientSecret = ConvertTo-SecureString -String "cfUmaOep8IcYCm2r?Fh2x2HenZgtR[=-" -AsPlainText -Force
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
    $TenantId = "324f7296-1869-4489-b11e-912351f38ead"#""

    .\run-task.ps1 -Username $userName -OldUrl $oldUrl -NewUrl $newUrl -OldServer $oldServer -DatasourceType $datasourceType -NewServer $newServer -OldDatabase $oldDatabase -NewDatabase $newDatabase -AccessRight $accesRight -Users $users -FilePattern $filePattern -Password $passWord -ClientId $clientId -WorkspaceName $groupName -Overwrite $overwrite -Create $create -Dataset $dataset -Action $action -UpdateAll $UpdateAll -ClientSecret $clientSecret -TenantId $TenantId 
}
finally {
    Write-Information "Done running the task"
}
