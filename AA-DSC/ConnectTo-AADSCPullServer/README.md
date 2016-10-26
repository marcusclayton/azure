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
* Start the runbook, and pass the name of an on-prem server
 * Requirements: Server must be joined to the same domain as the hyrbid worker, and allow PS remoting. A good test it to manually run an Invoke-Command from the hybrid worker targeting the new server with the "-ComputerName" parameter. 
* Verify the runbook completes successfully with no errors. 
* New nodes should appear in the "DSC Nodes" blade.

![picture alt](https://mcautomationgitresources.blob.core.windows.net/images/ConnectTo-AADSCPullServer-JobSuccess.jpg "Runbook Success")