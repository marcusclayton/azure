$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = "aadsc01"
            Role = "MgmtNode"
         },
         @{
            NodeName = "aadsc02"
         },
         @{
            NodeName = "aadsc03"
            Role = @("AppNode","Base")
         }
     )

    NonNodeData = @(
        @{
            Uri = "https://some.uri"
            Path = "C:\temp\armunique.json"
        }
    )
}

$rg = "automation"
$account = "automation"
$configName = "itWorks"

Start-AzureRmAutomationDscCompilationJob -ResourceGroupName $rg -AutomationAccountName $account -ConfigurationName $configName -ConfigurationData $ConfigData -Verbose