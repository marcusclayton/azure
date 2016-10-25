workflow ConnectTo-AADSCPullServer
{
    Param(
        [Parameter(Mandatory = $True)]
        [String] $computerName,
        [ValidateSet('$True','$False')]
        [String]$SafeMode = '$False'
    )

    $Cred = Get-AutomationPSCredential -Name 'Azure-ServicePrincipal'
    $TenantId = Get-AutomationVariable -Name 'TenantId'
    #$connectionName = 'Automation'
    $SubId = Get-AutomationVariable -Name 'SubscriptionId'
    try
    {
    # Get the connection "AzureRunAsConnection "

    "Logging in to Azure..."
    Login-AzureRmAccount `
        -ServicePrincipal `
        -Credential $Cred `
        -TenantId $TenantId `
        -Verbose
    "Setting context to a specific subscription"  

    }
    catch {
        throw "Error connecting..."

        <#if (!$servicePrincipalConnection)
        {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
        } else{
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
        #>
    }

    #Get-AzureRmResourceGroup -verbose
    
    
    $RG = Get-AutomationVariable -Name 'ResourceGroupName'
    $DSCMetaConfigFolder = "C:\Automation\AA-DSC"
    $AutomationAccountName = Get-AutomationVariable -Name 'AutomationAccountName'
    $DomainCred = Get-AutomationPSCredential -Name 'On-Prem Automation Account'
    
    $Params = @{
    ResourceGroupName = $RG; # The name of the ARM Resource Group that contains your Azure Automation Account
    AutomationAccountName = $AutomationAccountName; # The name of the Azure Automation Account where you want a node on-boarded to
    ComputerName = @("$computerName"); # The names of the computers that the meta configuration will be generated for
    OutputFolder = $DSCMetaConfigFolder;
    }
    
    if(!(Test-Path $DSCMetaConfigFolder)){
        New-Item -ItemType Directory -Name AA-DSC -Path C:\Automation\ -Force -Verbose
    }
    
    
    # Use PowerShell splatting to pass parameters to the Azure Automation cmdlet being invoked
    # For more info about splatting, run: Get-Help -Name about_Splatting
    
    Get-AzureRmAutomationDscOnboardingMetaconfig @Params -Force -Verbose
    $mofDir = Get-Item ($DSCMetaConfigFolder + "\DSCMetaConfigs\")
    $mofDir = $mofDir.FullName
    Set-DscLocalConfigurationManager -Path $mofDir -ComputerName $computerName -Credential $DomainCred -WhatIf:$SafeMode
    

}