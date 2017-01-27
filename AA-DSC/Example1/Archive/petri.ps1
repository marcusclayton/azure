# We begin defining a configuration that will be common to all our server nodes
# This will include some basics standard settings, including SNMP Services, DotNet framework
# Disabling the annoying IE Enhanced Security stuff, and finally installing my SCOM Agent
# Note that the SCOMAgent is actually a configuration of its own; this allows us to embed
# configurations within each other, making it easier to read and create complex configurations
 
configuration BaseServer
{
   WindowsFeature snmp
   {
      Ensure = "Present"
      Name = 'SNMP-Service'
   }
 
   WindowsFeature snmpwmi
   {
      Ensure = "Present"
      Name = 'SNMP-WMI-Provider'
      DependsOn= '[WindowsFeature]snmp'
   }
 
   WindowsFeature DotNet {
      Ensure = "Present"
      Name = "NET-Framework-45-Core"
   }
 
   Registry IEEnhanchedSecurity
   {
      # When "Present" then "IE Enhanced Security" will be "Disabled"
      Ensure = "Present"
      Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
      ValueName = "IsInstalled"
      ValueType = "DWord"
      ValueData = "0"
   }
 
   SCOMAgent InstallandRegister{}
}
 
# To leverge the power of DSC, we can define the configuration of our servers
# to be based any any combination of things, including physical and virtual.
# For virtual servers we could, for example, include integration components, while
# for physical servers we might want to deploy hardware management agents!
 
configuration VirtualServer
{
   BaseServer StandardBaseConfiguration {}
}
 
configuration PhysicalServer
{
   BaseServer StandardBaseConfiguration {}
 
   Dell DellManagementStuff
   {
      DependsOn  = '[BaseServer]JustTheBasics'
   }
}
 
# Of course to really leverage the power of DSC and PowerShell, our hash table is defined
# to describe the different roles that will be hosted on the node; therefore, we can then
# use that detail to define additional configuration instructions based on the roles
 
configuration UnconfiguredServer
{
   WindowsFeature PowerShellISE
   {
      Ensure = "Present"
      Name = 'PowerShell-ISE'
   }
}
 
configuration WebServer
{
 
   WindowsFeature IISServer
   {
      Ensure = "Present"
      Name = 'Web-WebServer'
   }
}
 
configuration FileServer
{
   WindowsFeature FileServices
   {
      Ensure = "Present"
      Name = 'FS-FileServer'
   }
 
   WindowsFeature FileResourceManagement
   {
      Ensure = "Present"
      Name = 'FS-Resource-Manager'
   }
}
 
configuration VMHost
{
   WindowsFeature Hyper-V
   {
      Ensure = "Present"
      Name = 'Hyper-V'
   }
}
 
# On our physical servers we choose to install the Dell Management tools
# But as these might be used on both Rack and Blade servers, we can break
# this into another configuration that can be referenced by other configurations!
 
configuration Dell
{
   Package DellOMSABinaries {
      Ensure    = "Present"
      Path      = "\\Server\Share\Dell\OpenManage\SysMgmtx64.msi"
      Name      = "Dell OpenManage Systems Management Software (64-Bit)"
      ProductID = "12345678-1234-12345678-12345678"
      Arguments = "ADDLOCAL=ALL"
   }
}
 
# Taking a similar approach, we can also manage our agents as different configurations,
# which can be easily rolled up into other configurations. In my case, this will be part
# of the base configuration for each server
 
Configuration SCOMAgent {
 
   file SCOMAgentInstaller
   {
      DestinationPath = 'c:\Installs\SCOM\Agent'
      SourcePath = "\\server\share\SCOM\Agent"
      Type = 'Directory'
      Recurse = 'False'
   }
 
   Package SCOMAgentPackage {
      Ensure = "Present"
      Name = "Microsoft Management Agent"
      Path = "C:\Installs\SCOM\Agent\MOMAgent.msi"
      Arguments = "USE_SETTINGS_FROM_AD=0 MANAGEMENT_GROUP=OM_Diginerve MANAGEMENT_SERVER_DNS=PDC-SC-OMMS01.diginerve.net ACTIONS_USE_COMPUTER_ACCOUNT=1 USE_MANUALLY_SPECIFIED_SETTINGS=1 SET_ACTIONS_ACCOUNT=1 AcceptEndUserLicenseAgreement=1"
      productId = "8B21425D-02F3-4B80-88CE-8F79B320D330"
      LogPath = "C:\Files\SCOMAgentInstallLog.txt"
      DependsOn = '[File]SCOMAgentInstaller'
   }
}
 
#
# The Heart of the Configuration! This is where all the work happens
# the Master Configuration accepts in the Configuration Data hash table to start running
# some very simple PowerShell logic to build out configurations for each server
# based on the details we hold in the hash table.
#
# Extending this configuration, you can create a profile ready for your enterprise.
# But don't forget to share it
# Create a copy at gist.github.com and put the links back in the comments!
#
 
configuration PetriDSC
{
   $DependsOn = $null
 
   if ($AllNodes.where({$_.ServerType -eq 'VM'}).NodeName)
   {
      node ($AllNodes.where({$_.ServerType -eq 'VM'})).NodeName
      {
         VirtualServer HyperV {}
         $DependsOn = '[VirtualServer]HyperV'
      }
   }
 
   if ($AllNodes.where({$_.ServerType -eq 'Physical'}).NodeName)
   {
      node ($AllNodes.where({$_.ServerType -eq 'Physical'})).NodeName
      {
         PhysicalServer Dell  {}
         $DependsOn = '[PhysicalServer]Dell'
      }
   }
 
   node ($AllNodes).NodeName
   {
      switch ($Node.Roles)
      {
         'WebServer'     { WebServer      WebServices    { DependsOn = $DependsOn } }
         'FileServer'    { FileServer     FileServices   { DependsOn = $DependsOn } }
         'VMHost'        { VMHost         VMServices     { DependsOn = $DependsOn } }
         default         { UnconfiguredServer NoRoleDefinedYet {} }
      }
   }
}