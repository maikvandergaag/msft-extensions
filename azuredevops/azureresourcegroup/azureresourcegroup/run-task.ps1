Trace-VstsEnteringInvocation $MyInvocation

. "$PSScriptRoot\ps_modules\Utility.ps1"

$serviceName = Get-VstsInput -Name ConnectedServiceName -Require
$groupName = Get-VstsInput -Name ResourceGroupName -Require
$location = Get-VstsInput -Name location -Require
$tags = Get-VstsInput -Name Tags
$lock = Get-VstsInput -Name Lock -Require -AsBool

$endpoint = Get-VstsEndpoint -Name $serviceName -Require
$targetAzurePs = ""

if($tags){
    $tagItems = @{}
    (ConvertFrom-Json $tags).psobject.properties | ForEach-Object { $tagItems[$_.Name] = $_.Value }
}
Update-PSModulePathForHostedAgent -targetAzurePs $targetAzurePs

try 
{
    # Initialize Azure.
    Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
    Initialize-AzModule -Endpoint $endpoint -azVersion $targetAzurePs
    if($tags){
        .\new-azureresourcegroup.ps1 -ResourceGroupName $groupName -Tags $tagItems -Lock $lock -Location $location
    }else{
        .\new-azureresourcegroup.ps1 -ResourceGroupName $groupName -Lock $lock -Location $location
    }

}catch{
    write-host $_
}
finally {
    if ($__vstsAzPSInlineScriptPath -and (Test-Path -LiteralPath $__vstsAzPSInlineScriptPath) ) {
        Remove-Item -LiteralPath $__vstsAzPSInlineScriptPath -ErrorAction 'SilentlyContinue'
    }

    Import-Module $PSScriptRoot\ps_modules\VstsAzureHelpers_
    Remove-EndpointSecrets
    Disconnect-AzureAndClearContext -ErrorAction SilentlyContinue
}
