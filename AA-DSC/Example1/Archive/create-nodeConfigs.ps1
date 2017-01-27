$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = "aadsc01"
            Role = "azureautomationhybridworker"
        },
        @{
            NodeName = "aadsc02"
        },
        @{
            NodeName = "*"
            Role = "vstsWorker"
        }
    )

    NonNodeData = @(
        @{
            Uri = "https://raw.githubusercontent.com/marcusclayton/temp/master/azuredeploy.json"
            Path = "C:\temp\armunique.json"
        }
    )
}

Start-AzureRmAutomationDscCompilationJob -ResourceGroupName "Automation" -AutomationAccountName "Automation" -ConfigurationName "MyServers" -ConfigurationData $ConfigData -Verbose