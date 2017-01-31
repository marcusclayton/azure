$ConfigData = @{
    "FeatureName" = "RSAT-DNS-Server"
    "IsPresent" = $true
}

$rg = "automation"
$account = "automation"
$configName = "ItWorksParams"

Start-AzureRmAutomationDscCompilationJob -ResourceGroupName $rg -AutomationAccountName $account -ConfigurationName $configName -ConfigurationData $ConfigData -Verbose