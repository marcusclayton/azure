Configuration Base
{
   WindowsFeature BITS
   {
      Ensure = "Present"
      Name = 'BITS'
   }

}

Configuration SevenZip {

    xRemoteFile 7zip {
        Uri = "http://www.7-zip.org/a/7z1604.msi"
        DestinationPath = "C:\temp\7z1604-dsc.msi"
    }

   Package SevenZipPackage {
      Ensure = "Present"
      Name = "7zip"
      Path = "C:\temp\7zip-dsc.exe"
      Arguments = '/q INSTALLDIR="C:\Program Files\7-Zip'
      productId = "23170F69-40C1-2701-1604-000001000000"
      LogPath = "C:\temp\7zip.txt"
      DependsOn = '[xRemoteFile]7zip'
   }
}

configuration Telnet
{
   WindowsFeature TelnetClient
   {
      Ensure = "Present"
      Name = 'Telnet-Client'
   }

}




Configuration MasterConfig {
   if ($AllNodes.where({$_.role -eq 'MgmtNode'}).NodeName){
        node MgmtConfig {

            Base Telnet {}
    }
   }


   if ($AllNodes.where({$_.role -eq 'AppNode'}).NodeName){
        node AppConfig {

            Base Telnet SevenZip {}
    }
   }


    if ($AllNodes.where({$_.role -eq 'Base'}).NodeName){
        node BaseConfig{
            Base {}
        }
    }
}