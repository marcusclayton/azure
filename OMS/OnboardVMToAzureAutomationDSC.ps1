# Define the parameters for Get-AzureRmAutomationDscOnboardingMetaconfig using PowerShell Splatting
$Params = @{
    ResourceGroupName = 'Automation'; # The name of the ARM Resource Group that contains your Azure Automation Account
    AutomationAccountName = 'Automation'; # The name of the Azure Automation Account where you want a node on-boarded to
    ComputerName = @('mdt01', 'scorch01','aadsc01.lab.cloudcents.net'); # The names of the computers that the meta configuration will be generated for
    OutputFolder = "C:\Automation\AA-DSC\";
}

# Use PowerShell splatting to pass parameters to the Azure Automation cmdlet being invoked
# For more info about splatting, run: Get-Help -Name about_Splatting
Login-AzureRmAccount
Get-AzureRmAutomationDscOnboardingMetaconfig @Params -Force