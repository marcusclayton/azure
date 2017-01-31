$ConfigData = @{
    AllNodes = @(
     )

    NonNodeData = @(
        @{
            Version = "1"
            Node = "Mgmt"
            FeatureList = @("Telnet-Client","RSAT-ADCS-Mgmt","RSAT-Clustering"
            )
        }
    )
}


$rg = "automation"
$account = "automation"
$configName = "Management"



Start-AzureRmAutomationDscCompilationJob -ResourceGroupName $rg -AutomationAccountName $account -ConfigurationName $configName -ConfigurationData $ConfigData -Verbose