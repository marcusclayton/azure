$Keys = $AAAcount = "Automation"
$rg = "automation"

Get-AzureRmAutomationAccount -Name $AAAcount -ResourceGroupName $rg -OutVariable AAAcount
$keys = $AAAcount | Get-AzureRmAutomationRegistrationInfo

[DscLocalConfigurationManager()]
configuration LCM {
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        $Keys
    )
    
    Settings {
        ConfigurationMode = 'ApplyAndAutoCorrect'
        RefreshMode = 'Pull'
        RefreshFrequencyMins = 30
        RebootNodeIfNeeded = $true
        ActionAfterReboot = 'ContinueConfiguration'
        ConfigurationModeFrequencyMins = 15
    }
    ConfigurationRepositoryWeb AADSC {
        ServerURL = $Keys.Endpoint
        RegistrationKey = $Keys.PrimaryKey
    }
    ResourceRepositoryWeb AADSC {
        ServerURL = $Keys.Endpoint
        RegistrationKey = $Keys.PrimaryKey
    }
    ReportServerWeb AADSC {
        ServerURL = $Keys.Endpoint
        RegistrationKey = $Keys.PrimaryKey
    }
}

$Keys | LCM -OutputPath $WorkingDir
ise $Workingdir\localhost.meta.mof