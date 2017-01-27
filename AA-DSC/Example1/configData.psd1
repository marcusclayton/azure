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

Start-AzureRmAutomationDscCompilationJob -ResourceGroupName "Automation" -AutomationAccountName "Automation" -ConfigurationName "ItWorks" -ConfigurationData $ConfigData -Verbose

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
            Uri = "https://raw.githubusercontent.com/marcusclayton/temp/master/azuredeploy.json"
            Path = "C:\temp\armunique.json"
        }
    )
}

Get-AzureRmAutomationAccount -ResourceGroupName automation -AutomationAccountName automation -OutVariable automation
$automation | Get-AzureRmAutomationDscNode -Name aadsc02 -OutVariable dscnode
$automation | Get-AzureRmAutomationDscNodeConfiguration -Name itworks.basecfg -OutVariable nodeconfig
$nodeconfig
$dscnode
$dscnode | Set-AzureRmAutomationDscNode -NodeConfigurationName $nodeconfig.name -Force -Verbose
invoke-command -ComputerName aadsc02 -ScriptBlock {Update-DscConfiguration -Wait -Verbose}

###
#Invoking a consistency check
#

<#
$server = "aadsc01"
Invoke-Command -ComputerName $server -ScriptBlock {
$dscProcessID = Get-WmiObject msft_providers | 
   Where-Object {$_.provider -like 'dsctimer'} | 
   Select-Object -ExpandProperty HostProcessIdentifier 

if ($dscProcessID -eq $null) {
    Write-Host "DSC timer is not running."
    return
}
Write-Host "Process ID: $dscProcessID"

Get-Process -Id $dscProcessID | Stop-Process -Force

Restart-Service -Name winmgmt -Force -Verbose
}




Invoke-CimMethod -computer $server -Namespace root/Microsoft/Windows/DesiredStateConfiguration -Cl MSFT_DSCLocalConfigurationManager -Method PerformRequiredConfigurationChecks -Arguments @{Flags = [System.UInt32]1} -Verbose



#>