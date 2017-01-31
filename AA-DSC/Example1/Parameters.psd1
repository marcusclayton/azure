$Params = @{
    "Version" = "3"
    "Node" = "Mgmt"
    "FeatureList" = "Telnet-Client","RSAT-ADCS-Mgmt","RSAT-Clustering"
}

$rg = "automation"
$account = "automation"
$configName = "Parameters"

Start-AzureRmAutomationDscCompilationJob -ResourceGroupName $rg -AutomationAccountName $account -ConfigurationName $configName -Parameters $Params -Verbose