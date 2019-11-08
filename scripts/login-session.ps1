$clientSecret = "aKv3@e-H-Y[KQR8bTMbmppsLTu9VGsg1"
$clientId ="baf82791-ad9f-4023-90db-b17e1c2d6ff8"
$tenantId = "324f7296-1869-4489-b11e-912351f38ead"


$passwd = ConvertTo-SecureString $clientSecret -AsPlainText -Force
$pscredential = New-Object System.Management.Automation.PSCredential($clientId, $passwd)
Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $tenantId