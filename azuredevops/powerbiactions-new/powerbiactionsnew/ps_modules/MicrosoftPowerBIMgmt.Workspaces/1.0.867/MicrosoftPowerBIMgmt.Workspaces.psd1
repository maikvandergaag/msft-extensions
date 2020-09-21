#
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#
# Module manifest for module 'MicrosoftPowerBIMgmt.Workspaces'
#

@{
    # Script module or binary module file associated with this manifest.
    RootModule = '.\lib\netstandard2.0\Microsoft.PowerBI.Commands.Workspaces.dll'

    # Version number of this module.
    ModuleVersion = '1.0.867'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    # ID used to uniquely identify this module
    GUID = '3137355e-2bac-4061-9bfb-25b18c8bce9a'

    # Author of this module
    Author = 'Microsoft Corporation'

    # Company or vendor of this module
    CompanyName = 'Microsoft Corporation'

    # Copyright statement for this module
    Copyright = 'Microsoft Corporation. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'Microsoft Power BI PowerShell - Workspace cmdlets for Microsoft Power BI'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '3.0'

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
     RequiredModules = @('MicrosoftPowerBIMgmt.Profile')

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess = @('Microsoft.PowerBI.Commands.Workspaces.format.ps1xml')

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    # FunctionsToExport = '*'

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @('Get-PowerBIWorkspace', 'Get-PowerBIWorkspaceMigrationStatus', 'Add-PowerBIWorkspaceUser', 'Remove-PowerBIWorkspaceUser', 'Set-PowerBIWorkspace', 'Restore-PowerBIWorkspace', 'New-PowerBIWorkspace')

    # Variables to export from this module
    # VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @('Add-PowerBIGroupUser', 'Get-PowerBIGroup', 'Get-PowerBIGroupMigrationStatus', 'Remove-PowerBIGroupUser', 'Set-PowerBIGroup', 'Restore-PowerBIGroup', 'New-PowerBIGroup')

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('PowerBI', 'Workspaces', 'Groups')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/Microsoft/powerbi-powershell/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/Microsoft/powerbi-powershell'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
                    ReleaseNotes = @'
Updates to existing cmdlets:
- Connect-PowerBIServiceAccount: added parameters -DiscoverUrl (string) to specify a custom service discovery url and -CustomEnvironment (string)
to specify the environment to choose.
- Invoke-PowerBIRestMethod: added parameter -TimeoutSec (int) to specify a client timeout in seconds.
'@

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = 'https://go.microsoft.com/fwlink/?linkid=2002111&clcid=0x409'

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}
# SIG # Begin signature block
# MIIdkgYJKoZIhvcNAQcCoIIdgzCCHX8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUjshtwThcgFUachrvff0pJovL
# WKWgghhuMIIE3jCCA8agAwIBAgITMwAAAVMi29XcAx7KbwAAAAABUzANBgkqhkiG
# 9w0BAQUFADB3MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEw
# HwYDVQQDExhNaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EwHhcNMTkxMjE5MDExMjU5
# WhcNMjEwMzE3MDExMjU5WjCBzjELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjEpMCcGA1UECxMgTWljcm9zb2Z0IE9wZXJhdGlvbnMgUHVlcnRvIFJp
# Y28xJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNOOkY3QTYtRTI1MS0xNTBBMSUwIwYD
# VQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNlMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAq1diK9JlonJ+oylzVWABNR+Ch+1DFBtELj+s2Clp
# mny7jKTaKBtfJj/VXgmPb0clmTSW/ORG4E7U6a+byrPi+2TRm+KPnOUhpjEWkrwU
# s7p9Yri6MkYVIpH6u7hDFpftVw0cnqD75GriLHPxAL9gXnWCijYmWrAwbQmiFCnv
# KLNd57OoyHOKnbNoE/ZY3nfXXiMblVCfiEeAk3c/FhEC1ZgePKWzPv3cDf77Clka
# DtGGkL1PLQOWKGlED6WBlKQWwwBbrRCcKn/DFhQjBVL7hKBvKIx41Onu1q4ZR3V3
# P4cKvhpgVtBzgrWyV49NW6zpbhTiNB8Hv0KJBmRSYpo5wQIDAQABo4IBCTCCAQUw
# HQYDVR0OBBYEFKYM4eA/3NrcTBY4Uo+HjtARq+DTMB8GA1UdIwQYMBaAFCM0+NlS
# RnAK7UD7dvuzK7DDNbMPMFQGA1UdHwRNMEswSaBHoEWGQ2h0dHA6Ly9jcmwubWlj
# cm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY3Jvc29mdFRpbWVTdGFtcFBD
# QS5jcmwwWAYIKwYBBQUHAQEETDBKMEgGCCsGAQUFBzAChjxodHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY3Jvc29mdFRpbWVTdGFtcFBDQS5jcnQw
# EwYDVR0lBAwwCgYIKwYBBQUHAwgwDQYJKoZIhvcNAQEFBQADggEBAEPT3fFVLrkO
# s336Dh2XtV7NzB1XvFiBhTeDEWCAKb67K1Et2Qudz8wk37hfWgX0DIYi0lvDrZxf
# iLedK9xl/+CGKC8Cnle0c4kQxHzsJMh9TrYzfMkxzXQpyMAXm8gyzInlM1khJobC
# olWP97sqZdcESpLo5mWVz6uuVys59KaVND4VictBo1mH+UpZ4PVyTgpUgB0M5egL
# I7PWSAwfPVwadiKaREjVpd02X3mQWcCyeFrFLcj5zL6bOWArxBWVAQ+okjDr6utc
# 9bdm3DodUkNCauvvpVQhR+WZ9E6KoIfsgLrFfW1WhtMmF1msCk0bOdsMAwjD2gXM
# uuGf3UmLPt0wggX/MIID56ADAgECAhMzAAABh3IXchVZQMcJAAAAAAGHMA0GCSqG
# SIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# KDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTEwHhcNMjAw
# MzA0MTgzOTQ3WhcNMjEwMzAzMTgzOTQ3WjB0MQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9z
# b2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNyb3NvZnQgQ29ycG9yYXRpb24w
# ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDOt8kLc7P3T7MKIhouYHew
# MFmnq8Ayu7FOhZCQabVwBp2VS4WyB2Qe4TQBT8aBznANDEPjHKNdPT8Xz5cNali6
# XHefS8i/WXtF0vSsP8NEv6mBHuA2p1fw2wB/F0dHsJ3GfZ5c0sPJjklsiYqPw59x
# J54kM91IOgiO2OUzjNAljPibjCWfH7UzQ1TPHc4dweils8GEIrbBRb7IWwiObL12
# jWT4Yh71NQgvJ9Fn6+UhD9x2uk3dLj84vwt1NuFQitKJxIV0fVsRNR3abQVOLqpD
# ugbr0SzNL6o8xzOHL5OXiGGwg6ekiXA1/2XXY7yVFc39tledDtZjSjNbex1zzwSX
# AgMBAAGjggF+MIIBejAfBgNVHSUEGDAWBgorBgEEAYI3TAgBBggrBgEFBQcDAzAd
# BgNVHQ4EFgQUhov4ZyO96axkJdMjpzu2zVXOJcswUAYDVR0RBEkwR6RFMEMxKTAn
# BgNVBAsTIE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1ZXJ0byBSaWNvMRYwFAYDVQQF
# Ew0yMzAwMTIrNDU4Mzg1MB8GA1UdIwQYMBaAFEhuZOVQBdOCqhc3NyK1bajKdQKV
# MFQGA1UdHwRNMEswSaBHoEWGQ2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lv
# cHMvY3JsL01pY0NvZFNpZ1BDQTIwMTFfMjAxMS0wNy0wOC5jcmwwYQYIKwYBBQUH
# AQEEVTBTMFEGCCsGAQUFBzAChkVodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtp
# b3BzL2NlcnRzL01pY0NvZFNpZ1BDQTIwMTFfMjAxMS0wNy0wOC5jcnQwDAYDVR0T
# AQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAixmyS6E6vprWD9KFNIB9G5zyMuIj
# ZAOuUJ1EK/Vlg6Fb3ZHXjjUwATKIcXbFuFC6Wr4KNrU4DY/sBVqmab5AC/je3bpU
# pjtxpEyqUqtPc30wEg/rO9vmKmqKoLPT37svc2NVBmGNl+85qO4fV/w7Cx7J0Bbq
# k19KcRNdjt6eKoTnTPHBHlVHQIHZpMxacbFOAkJrqAVkYZdz7ikNXTxV+GRb36tC
# 4ByMNxE2DF7vFdvaiZP0CVZ5ByJ2gAhXMdK9+usxzVk913qKde1OAuWdv+rndqkA
# Im8fUlRnr4saSCg7cIbUwCCf116wUJ7EuJDg0vHeyhnCeHnBbyH3RZkHEi2ofmfg
# nFISJZDdMAeVZGVOh20Jp50XBzqokpPzeZ6zc1/gyILNyiVgE+RPkjnUQshd1f1P
# Mgn3tns2Cz7bJiVUaqEO3n9qRFgy5JuLae6UweGfAeOo3dgLZxikKzYs3hDMaEtJ
# q8IP71cX7QXe6lnMmXU/Hdfz2p897Zd+kU+vZvKI3cwLfuVQgK2RZ2z+Kc3K3dRP
# z2rXycK5XCuRZmvGab/WbrZiC7wJQapgBodltMI5GMdFrBg9IeF7/rP4EqVQXeKt
# evTlZXjpuNhhjuR+2DMt/dWufjXpiW91bo3aH6EajOALXmoxgltCp1K7hrS6gmsv
# j94cLRf50QQ4U8QwggYHMIID76ADAgECAgphFmg0AAAAAAAcMA0GCSqGSIb3DQEB
# BQUAMF8xEzARBgoJkiaJk/IsZAEZFgNjb20xGTAXBgoJkiaJk/IsZAEZFgltaWNy
# b3NvZnQxLTArBgNVBAMTJE1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhv
# cml0eTAeFw0wNzA0MDMxMjUzMDlaFw0yMTA0MDMxMzAzMDlaMHcxCzAJBgNVBAYT
# AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xITAfBgNVBAMTGE1pY3Jvc29mdCBU
# aW1lLVN0YW1wIFBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJ+h
# bLHf20iSKnxrLhnhveLjxZlRI1Ctzt0YTiQP7tGn0UytdDAgEesH1VSVFUmUG0KS
# rphcMCbaAGvoe73siQcP9w4EmPCJzB/LMySHnfL0Zxws/HvniB3q506jocEjU8qN
# +kXPCdBer9CwQgSi+aZsk2fXKNxGU7CG0OUoRi4nrIZPVVIM5AMs+2qQkDBuh/NZ
# MJ36ftaXs+ghl3740hPzCLdTbVK0RZCfSABKR2YRJylmqJfk0waBSqL5hKcRRxQJ
# gp+E7VV4/gGaHVAIhQAQMEbtt94jRrvELVSfrx54QTF3zJvfO4OToWECtR0Nsfz3
# m7IBziJLVP/5BcPCIAsCAwEAAaOCAaswggGnMA8GA1UdEwEB/wQFMAMBAf8wHQYD
# VR0OBBYEFCM0+NlSRnAK7UD7dvuzK7DDNbMPMAsGA1UdDwQEAwIBhjAQBgkrBgEE
# AYI3FQEEAwIBADCBmAYDVR0jBIGQMIGNgBQOrIJgQFYnl+UlE/wq4QpTlVnkpKFj
# pGEwXzETMBEGCgmSJomT8ixkARkWA2NvbTEZMBcGCgmSJomT8ixkARkWCW1pY3Jv
# c29mdDEtMCsGA1UEAxMkTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9y
# aXR5ghB5rRahSqClrUxzWPQHEy5lMFAGA1UdHwRJMEcwRaBDoEGGP2h0dHA6Ly9j
# cmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL21pY3Jvc29mdHJvb3Rj
# ZXJ0LmNybDBUBggrBgEFBQcBAQRIMEYwRAYIKwYBBQUHMAKGOGh0dHA6Ly93d3cu
# bWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljcm9zb2Z0Um9vdENlcnQuY3J0MBMG
# A1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqGSIb3DQEBBQUAA4ICAQAQl4rDXANENt3p
# tK132855UU0BsS50cVttDBOrzr57j7gu1BKijG1iuFcCy04gE1CZ3XpA4le7r1ia
# HOEdAYasu3jyi9DsOwHu4r6PCgXIjUji8FMV3U+rkuTnjWrVgMHmlPIGL4UD6ZEq
# JCJw+/b85HiZLg33B+JwvBhOnY5rCnKVuKE5nGctxVEO6mJcPxaYiyA/4gcaMvnM
# MUp2MT0rcgvI6nA9/4UKE9/CCmGO8Ne4F+tOi3/FNSteo7/rvH0LQnvUU3Ih7jDK
# u3hlXFsBFwoUDtLaFJj1PLlmWLMtL+f5hYbMUVbonXCUbKw5TNT2eb+qGHpiKe+i
# myk0BncaYsk9Hm0fgvALxyy7z0Oz5fnsfbXjpKh0NbhOxXEjEiZ2CzxSjHFaRkMU
# vLOzsE1nyJ9C/4B5IYCeFTBm6EISXhrIniIh0EPpK+m79EjMLNTYMoBMJipIJF9a
# 6lbvpt6Znco6b72BJ3QGEe52Ib+bgsEnVLaxaj2JoXZhtG6hE6a/qkfwEm/9ijJs
# sv7fUciMI8lmvZ0dhxJkAj0tr1mPuOQh5bWwymO0eFQF1EEuUKyUsKV4q7OglnUa
# 2ZKHE3UiLzKoCG6gW4wlv6DvhMoh1useT8ma7kng9wFlb4kLfchpyOZu6qeXzjEp
# /w7FW1zYTRuh2Povnj8uVRZryROj/TCCB3owggVioAMCAQICCmEOkNIAAAAAAAMw
# DQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5n
# dG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhv
# cml0eSAyMDExMB4XDTExMDcwODIwNTkwOVoXDTI2MDcwODIxMDkwOVowfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMTCCAiIwDQYJKoZIhvcNAQEBBQADggIP
# ADCCAgoCggIBAKvw+nIQHC6t2G6qghBNNLrytlghn0IbKmvpWlCquAY4GgRJun/D
# DB7dN2vGEtgL8DjCmQawyDnVARQxQtOJDXlkh36UYCRsr55JnOloXtLfm1OyCizD
# r9mpK656Ca/XllnKYBoF6WZ26DJSJhIv56sIUM+zRLdd2MQuA3WraPPLbfM6XKEW
# 9Ea64DhkrG5kNXimoGMPLdNAk/jj3gcN1Vx5pUkp5w2+oBN3vpQ97/vjK1oQH01W
# KKJ6cuASOrdJXtjt7UORg9l7snuGG9k+sYxd6IlPhBryoS9Z5JA7La4zWMW3Pv4y
# 07MDPbGyr5I4ftKdgCz1TlaRITUlwzluZH9TupwPrRkjhMv0ugOGjfdf8NBSv4yU
# h7zAIXQlXxgotswnKDglmDlKNs98sZKuHCOnqWbsYR9q4ShJnV+I4iVd0yFLPlLE
# tVc/JAPw0XpbL9Uj43BdD1FGd7P4AOG8rAKCX9vAFbO9G9RVS+c5oQ/pI0m8GLhE
# fEXkwcNyeuBy5yTfv0aZxe/CHFfbg43sTUkwp6uO3+xbn6/83bBm4sGXgXvt1u1L
# 50kppxMopqd9Z4DmimJ4X7IvhNdXnFy/dygo8e1twyiPLI9AN0/B4YVEicQJTMXU
# pUMvdJX3bvh4IFgsE11glZo+TzOE2rCIF96eTvSWsLxGoGyY0uDWiIwLAgMBAAGj
# ggHtMIIB6TAQBgkrBgEEAYI3FQEEAwIBADAdBgNVHQ4EFgQUSG5k5VAF04KqFzc3
# IrVtqMp1ApUwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGG
# MA8GA1UdEwEB/wQFMAMBAf8wHwYDVR0jBBgwFoAUci06AjGQQ7kUBU7h6qfHMdEj
# iTQwWgYDVR0fBFMwUTBPoE2gS4ZJaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3Br
# aS9jcmwvcHJvZHVjdHMvTWljUm9vQ2VyQXV0MjAxMV8yMDExXzAzXzIyLmNybDBe
# BggrBgEFBQcBAQRSMFAwTgYIKwYBBQUHMAKGQmh0dHA6Ly93d3cubWljcm9zb2Z0
# LmNvbS9wa2kvY2VydHMvTWljUm9vQ2VyQXV0MjAxMV8yMDExXzAzXzIyLmNydDCB
# nwYDVR0gBIGXMIGUMIGRBgkrBgEEAYI3LgMwgYMwPwYIKwYBBQUHAgEWM2h0dHA6
# Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvZG9jcy9wcmltYXJ5Y3BzLmh0bTBA
# BggrBgEFBQcCAjA0HjIgHQBMAGUAZwBhAGwAXwBwAG8AbABpAGMAeQBfAHMAdABh
# AHQAZQBtAGUAbgB0AC4gHTANBgkqhkiG9w0BAQsFAAOCAgEAZ/KGpZjgVHkaLtPY
# dGcimwuWEeFjkplCln3SeQyQwWVfLiw++MNy0W2D/r4/6ArKO79HqaPzadtjvyI1
# pZddZYSQfYtGUFXYDJJ80hpLHPM8QotS0LD9a+M+By4pm+Y9G6XUtR13lDni6WTJ
# RD14eiPzE32mkHSDjfTLJgJGKsKKELukqQUMm+1o+mgulaAqPyprWEljHwlpblqY
# luSD9MCP80Yr3vw70L01724lruWvJ+3Q3fMOr5kol5hNDj0L8giJ1h/DMhji8MUt
# zluetEk5CsYKwsatruWy2dsViFFFWDgycScaf7H0J/jeLDogaZiyWYlobm+nt3TD
# QAUGpgEqKD6CPxNNZgvAs0314Y9/HG8VfUWnduVAKmWjw11SYobDHWM2l4bf2vP4
# 8hahmifhzaWX0O5dY0HjWwechz4GdwbRBrF1HxS+YWG18NzGGwS+30HHDiju3mUv
# 7Jf2oVyW2ADWoUa9WfOXpQlLSBCZgB/QACnFsZulP0V3HjXG0qKin3p6IvpIlR+r
# +0cjgPWe+L9rt0uX4ut1eBrs6jeZeRhL/9azI2h15q/6/IvrC4DqaTuv/DDtBEyO
# 3991bWORPdGdVk5Pv4BXIqF4ETIheu9BCrE/+6jMpF3BoYibV3FWTkhFwELJm3Zb
# CoBIa/15n8G9bW1qyVJzEw16UM0xggSOMIIEigIBATCBlTB+MQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQgQ29k
# ZSBTaWduaW5nIFBDQSAyMDExAhMzAAABh3IXchVZQMcJAAAAAAGHMAkGBSsOAwIa
# BQCggaIwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFIWd4FzlNyPZCU+96snZQyC7
# mRwhMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBho
# dHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEBBQAEggEAzBlxyqY3
# u/9+MEo4sNaprQQAbp53r+Czc1y18QEcGK6KlPnTW+3V0vp+jByaSvb7NuTXyxUt
# JP4DyGIpYUqtQjphl5tbzpeRCw5viPVLELF8e5Zc4KlAoD1EmI9+jPMSBXbc2Hpx
# t3pNFsTRgopu+EYkF6Lg+YL5Y29oj0SjrMr8UUoc3/WUbPb/sZNr84oYbxMdIujf
# UuhCwP6/MAKW2xJQI+j8CCckw3bsnWkUOo0W53ixWYDl78G6bzS2ez8ZjjOzuSUr
# j9y5CkP36Mza324EA+4NsEdgCgd1wFONi+Xyvol697jHjz+JnezpBinH3k8ScYS4
# CjyAwiT6CFXSDqGCAigwggIkBgkqhkiG9w0BCQYxggIVMIICEQIBATCBjjB3MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEwHwYDVQQDExhNaWNy
# b3NvZnQgVGltZS1TdGFtcCBQQ0ECEzMAAAFTItvV3AMeym8AAAAAAVMwCQYFKw4D
# AhoFAKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8X
# DTIwMDgwNzE3NTcyOVowIwYJKoZIhvcNAQkEMRYEFJOnwkChvpLnYZhk/DDIyjbA
# lUUGMA0GCSqGSIb3DQEBBQUABIIBACnM+61HTFAzEENTX59j/2Lhq15L9yANgfwS
# EXHUz25omvTH7EFUwLDz124waZZmnrU5D2kyqXwrEzK/ewsjFfE8nEhYGYUC9mn/
# pQSU0sMeuS08ql8f/WMt1C1+1IBnIhOxRiIfmGXmzCuAymRCStl4p0WJ2ElS6/fO
# xnakLEeILMjpvXGAOn/zILQV6L+IgD+uZBSftiph0Ai4cWMl1c1924Q3D0Z/1XTo
# b93/LdJDd8mLkMCMaOiyitjDalx2gZ/9CmZh2xZfVLIY6FWXSaKBpbMIAFju+RVR
# JNpC5mXLC0C26i0v2+AZk8idm9airwhoIUwI7O52c78ljjv8gac=
# SIG # End signature block
