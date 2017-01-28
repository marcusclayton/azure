$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = "aadsc01"
            Role = "MgmtNode"
         },
         @{
            NodeName = "aadsc02"
            Role = "TestBox"
            Feature = "RSAT-DNS-Server"
         },
         @{
            NodeName = "aadsc03"
            Role = @("AppNode","Base")
         }
     )

    NonNodeData = @(
        @{
            SomeMessage = "Message From Config Data"
            Uri = "https://some.uri"
            Path = "C:\temp\armunique.json"
        }
    )
}

$rg = "automation"
$account = "automation"
$configName = "itWorks2"

Start-AzureRmAutomationDscCompilationJob -ResourceGroupName $rg -AutomationAccountName $account -ConfigurationName $configName -ConfigurationData $ConfigData -Verbose