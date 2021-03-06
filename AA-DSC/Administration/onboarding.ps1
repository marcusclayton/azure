#Part 3: https://channel9.msdn.com/Blogs/MVP-Azure/Azure-Automation-DSC-Part-3-Onboarding-Azure-Windows-Nodes 

$AAAcount = "Automation"
$rg = "automation"

Get-AzureRmAutomationAccount -Name $AAAcount -ResourceGroupName $rg -OutVariable AAAcount


#After running the command, the output shows which JSON template was run in the "templatelink.uri" property:
#saved to github repo >> registerazurevmbyextension.json
# https://eus2oaasibizamarketprod1.blob.core.windows.net/automationdscpreview/azuredeployV2.json 

#looking at the template, lines 93/94 show the microsoft.powershell.dsc extension was used to onboard the node
#processes an archive prepared by the automtion team
#we find the archive URI in the output of the register command (above), parameters.moduleUrl
#https://eus2oaasibizamarketprod1.blob.core.windows.net/automationdscpreview/RegistrationMetaConfigV2.zip
#download the zip, extract content, and look to see which configuration was run by the extension
Invoke-WebRequest -Uri "https://eus2oaasibizamarketprod1.blob.core.windows.net/automationdscpreview/RegistrationMetaConfigV2.zip" -Method get -OutFile C:\GitRepos\azure\AA-DSC\Administration\modulesUrl.zip -Verbose
Expand-Archive C:\GitRepos\azure\AA-DSC\Administration\modulesUrl.zip  -DestinationPath C:\GitRepos\azure\AA-DSC\Administration\

# contains >> RegistrationMetaConfigV2.ps1 (meta mof to configure the LCM)

# requires a registration key and API endpoint
# to see how this works on the Azure VM, connect to it (by IP or host name) 

($ip = get-azurermpublicipaddress -resourcegroup demo01).IpAddress
enter-pssession -computername $ip -credential "blah"
get-dsclocalconfigurationmanager

# notice: refresh mode: pull ; refreshfrequencymins: 30
# Uses certificate after registering with the access key. 
# Creates a certificate locally, and exchanges it with the automation account
# A good/safe practice to regenerate your automation account keys

get-childitem -Path Cert:\LocalMachine\My
#Look for subject: "CN=dsc-oaas"

# trigger a refresh on a node 
Update-DscConfiguration -Wait -Verbose
Get-DscConfiguration #Look at properties: configurationname, resourceid, type
Test-DscConfiguration  #tests whether the desired state for the resource(s) has been met. should output True

#assigning a node via ps
Get-AzureRmAutomationAccount -ResourceGroupName automation -AutomationAccountName automation -OutVariable automation
$automation | Get-AzureRmAutomationDscNode -Name aadsc02 -OutVariable dscnode
$automation | Get-AzureRmAutomationDscNodeConfiguration -Name itworks.basecfg -OutVariable nodeconfig
$nodeconfig
$dscnode
$dscnode | Set-AzureRmAutomationDscNode -NodeConfigurationName $nodeconfig.name -Force -Verbose

#This
invoke-command -ComputerName aadsc02 -ScriptBlock {
    Update-DscConfiguration -Wait -Verbose
    Get-DscConfiguration
    Test-DscConfiguration

}
#or This
New-CimSession -Credential "" -ComputerName "" -OutVariable cimsession
Update-DscConfiguration -CimSession $cimsession -Wait -Verbose
Get-DscConfiguration -CimSession $cimsession
Test-DscConfiguration -CimSession $cimsession


######################################################
######################################################
# Onboarding on-prem nodes, windows and linux
######################################################
######################################################

# Part 4: https://channel9.msdn.com/Blogs/MVP-Azure/Azure-Automation-DSC-Part-4-Advanced-onboarding-1

#Acquire prebaked meta.mof
$AAAcount = "Automation"
$rg = "automation"
$workingdir = "C:\GitRepos\azure\AA-DSC\Administration\Exclude\"

Get-AzureRmAutomationAccount -Name $AAAcount -ResourceGroupName $rg -OutVariable AAAcount
$AAAcount | Get-AzureRmAutomationDscOnboardingMetaconfig -OutputFolder $workingdir
#view it
ise $workingdir\dscmetaconfigs\localhost.meta.mof
# SHows registration keys, and registration URL
#We'll create out own mof, using the same key and endpoint URLs

#script available: https://github.com/marcusclayton/azure/blob/master/AA-DSC/Administration/GenerateMetaMof.ps1
#produces custom mof

#Onboard an on-prem node using our custom mof
$PSSessionArgs = @{
    ComputerName = "buildagent"
    Credential = (Get-credential)
}

$PSSession = new-pssession @PSSessionArgs
copy-item "<customMOFPathHERE" -tosession $PSSession #DOIng this manually
#used invoke-command method instead
#copied MOF over to C:\temp on 'buildagent'

invoke-command -computer buildagent -ScriptBlock {
    set-location C:\temp
    get-dsclocalconfigurationmanager #Before changes
    Set-dsclocalconfigurationmanager -Path C:\temp -verbose -Force
    get-dsclocalconfigurationmanager
}

#check status
$AAAcount | Get-AzureRmAutomationDscNode | select name

#Inspect the MOF (wrap in invoke statement for remote host)
get-content C:\windows\System32\configuration\metaconfig.mof -encoding unicode
#Look for reg key (wrap in invoke statement for remote host)
get-content C:\windows\System32\configuration\metaconfig.mof -encoding unicode | select-string 'RegistrationKey'
get-content C:\temp\localhost.meta.mof | select-string 'RegistrationKey'
remove-item C:\temp\localhost.meta.mof  #best practice to remove the MOF from file system after used

#View the certificate being used in place of the registration key after configuring the LCM
get-childitem -Path Cert:\localhost\my | select-object *
$thumbprint  = (get-childitem -Path cert:\localmachine\my\{thumbprinthere}).thumbprint

#The only way to know which certificate is being used for authentication as this is not imbedded in the LCM settings
get-content C:\windows\system32\configuration\dscenginecache.mof -encoding unicode | select-string $thumbprint

#Onboard Centos: Starts in part 4 @ 7:17
#Onboard ubuntu: Starts in part 4 @ 13:06


##################
### Part 5: Onboarding Azure VM's with powershell and ARM JSON templates (windows and linux)
#############

https://channel9.msdn.com/Blogs/MVP-Azure/Azure-Automation-DSC-Part-5-Advanced-onboarding-2

##################
### Part 6: use parameters and assets with configurations
### as well as the use of custom DSC resources and import pre-compiled MOF files
##################

https://channel9.msdn.com/Blogs/MVP-Azure/Azure-Automation-DSC-Part-6-Advanced-Configurations




#misc
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