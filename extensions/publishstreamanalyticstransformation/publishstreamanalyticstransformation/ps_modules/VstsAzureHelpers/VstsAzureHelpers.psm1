# Private module-scope variables.
$script:azureModule = $null
$script:azureRMProfileModule = $null

# Override the DebugPreference.
if ($global:DebugPreference -eq 'Continue') {
    Write-Verbose '$OVERRIDING $global:DebugPreference from ''Continue'' to ''SilentlyContinue''.'
    $global:DebugPreference = 'SilentlyContinue'
}

# Import the loc strings.
Import-VstsLocStrings -LiteralPath $PSScriptRoot/module.json

# Dot source the private functions.
. $PSScriptRoot/InitializeFunctions.ps1
. $PSScriptRoot/ImportFunctions.ps1

# This is the only public function.
function Initialize-Azure {
    [CmdletBinding()]
    param( [string] $azurePsVersion )
    Trace-VstsEnteringInvocation $MyInvocation
    try {
        # Get the inputs.
        $serviceNameInput = Get-VstsInput -Name ConnectedServiceNameSelector -Default 'ConnectedServiceName'
        $serviceName = Get-VstsInput -Name $serviceNameInput -Default (Get-VstsInput -Name DeploymentEnvironmentName)
        if (!$serviceName) {
            # Let the task SDK throw an error message if the input isn't defined.
            Get-VstsInput -Name $serviceNameInput -Require
        }

        $endpoint = Get-VstsEndpoint -Name $serviceName -Require
        $storageAccount = Get-VstsInput -Name StorageAccount

        # Determine which modules are preferred.
        $preferredModules = @( )
        if ($endpoint.Auth.Scheme -eq 'ServicePrincipal') {
            $preferredModules += 'AzureRM'
        } elseif ($endpoint.Auth.Scheme -eq 'UserNamePassword') {
            $preferredModules += 'Azure'
            $preferredModules += 'AzureRM'
        } else {
            $preferredModules += 'Azure'
        }

        # Import/initialize the Azure module.
        Import-AzureModule -PreferredModule $preferredModules -azurePsVersion $azurePsVersion
        Initialize-AzureSubscription -Endpoint $endpoint -StorageAccount $storageAccount
    } finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }
}

function Get-ResourceGroupName {
    param([String] [Parameter(Mandatory = $true)] $resourceName,
          [String] [Parameter(Mandatory = $true)] $resourceType)
    try {
        Write-VstsTaskVerbose -Message "[Azure Call] Getting resource details for resource: $resourceName with resource type: $resourceType"
        $resourceDetails = (Get-AzureRMResource -ErrorAction Stop) | Where-Object { $_.ResourceName -eq $resourceName -and $_.ResourceType -eq $resourceType } -Verbose
        Write-VstsTaskVerbose -Message "[Azure Call] Retrieved resource details successfully for resource: $resourceName with resource type: $resourceType"   
        $resourceGroupName = $resourceDetails.ResourceGroupName  
        Write-VstsTaskVerbose -Message "Resource Group Name for '$resourceName' of type '$resourceType': '$resourceGroupName'."
        return $resourceGroupName
    }
    finally {
        if ([string]::IsNullOrEmpty($resourceGroupName)) {
            throw (Get-VstsLocString -Key AZ_ResourceNotFound0 -ArgumentList $resourceName)
        }
    }
}

function Get-StreamAnalyticsJobGroupName  {
	param([String] [Parameter(Mandatory = $true)] $resourceName)
   
	return Get-ResourceGroupName -resourceName $resourceName -resourceType "Microsoft.StreamAnalytics/StreamingJobs"
}

# Export only the public function.
Export-ModuleMember -Function Initialize-Azure
Export-ModuleMember -Function Get-ResourceGroupName
Export-MOduleMember -Function Get-StreamAnalyticsJobGroupName