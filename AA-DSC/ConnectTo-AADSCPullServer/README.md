## Prepare the infrastructure ##
 * Set up both an Azure Automation account and OMS workspace.
 * Set up an Azure Automation Hybrid Runbook Worker in your lab/on-prem environment.
  * Install Azure PowerShell 3.0 on the hybrid worker (use WPI here). 

## Prepare AA DSC Assets ##
* Create the following AA credential assets which support the runbook
 * On-prem credential object
 * Create an Azure Service Principal account following this guide, define the account as an AA credential. 
* Create the following AA variable assets which support the runbook
 * Azure Automation resource group name: ARM RG which contains your AA account
 * Azure Automation account name: name of the AA account where the node will be on-boarded
 * Azure Subscription ID: no explanation required, right?
 * Azure Tenant ID

## Running the... Runbook ##
* Import the ConnectTo-AADSCPullServer.ps1 Runbook