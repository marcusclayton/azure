workflow Test
{
    Param(
        [Object]$WebhookData
    )

    #Integrate webhook: https://github.com/Azure/azure-content/blob/master/articles/automation/automation-webhooks.md 
    
    # Collect properties of WebhookData
        $WebhookName    =   $WebhookData.WebhookName
        $WebhookHeaders =   $WebhookData.RequestHeader
        $WebhookBody    =   $WebhookData.RequestBody

    # Collect individual headers. VMList converted from JSON.
        $From = $WebhookHeaders.From
        $computerNames = ConvertFrom-Json -InputObject $WebhookBody
        $SafeMode = $WebhookHeaders.SafeMode
        if($SafeMode -like '$False' -or $SafeMode -like 'False'){
            $SafeMode = $False
        } else{
            $SafeMode = $True
        }
        
        "Runbook started from webhook $WebhookName by $From. Running in Safe Mode: $SafeMode."

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
    
    if(!(Test-Path $DSCMetaConfigFolder)){
        New-Item -ItemType Directory -Name AA-DSC -Path C:\Automation\ -Force -Verbose
    }

    $computerList = @()
    
    foreach($computerName in $computernames){
        $computerList += $computerName.name         
    }

    $Params = @{
        ResourceGroupName = $RG; # The name of the ARM Resource Group that contains your Azure Automation Account
        AutomationAccountName = $AutomationAccountName; # The name of the Azure Automation Account where you want a node on-boarded to
        ComputerName = $computerList; # The names of the computers that the meta configuration will be generated for
        OutputFolder = $DSCMetaConfigFolder;
    }

    # Use PowerShell splatting to pass parameters to the Azure Automation cmdlet being invoked
    # For more info about splatting, run: Get-Help -Name about_Splatting

    Get-AzureRmAutomationDscOnboardingMetaconfig @Params -Force -Verbose

    #$computerList = $computerList -join ","
    #$ComputerList = $computerList.replace("`"","")
    $mofDir = Get-Item ($DSCMetaConfigFolder + "\DSCMetaConfigs\")
    $mofDir = $mofDir.FullName
    $computerList | %{Set-DscLocalConfigurationManager -Path $mofDir -ComputerName $_ -Credential $DomainCred -WhatIf:$SafeMode}

    #write-output -inputobject $computerList
    #Write-Output -inputobject $apply

}