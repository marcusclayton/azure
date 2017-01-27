$ConfigurationData = @{
   AllNodes = @(
      @{NodeName = 'PDC-SC-DC01';    ServerType='VM';       Roles='ADService'},
      @{NodeName = 'PDC-SC-VMM01';   ServerType='VM';       Roles='WebServer'},
      @{NodeName = 'PDC-FS-SMB01';   ServerType='VM';       Roles='FileServer'}
      @{NodeName = 'PDC-VM-HOST01';  ServerType='Physical'; Roles=@('VMHost','FileServer')}
   )
}