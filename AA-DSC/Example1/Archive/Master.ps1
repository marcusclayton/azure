Configuration Master {
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    if ($AllNodes.where({$_.role -eq 'AppNode'}).NodeName){

        node AppHostConfig {

            xRemoteFile SevenZip {
                Uri = "http://www.7-zip.org/a/7z1604.msi"
                DestinationPath = "C:\temp\7z1604-dsc.msi"
            }

            Package SevenZipPackage {
                Ensure = "Present"
                Name = "7zip"
                Path = "C:\temp\7zip-dsc.exe"
                Arguments = '/q INSTALLDIR="C:\Program Files\7-Zip'
                productId = "23170F69-40C1-2701-1604-000001000000"
                LogPath = "C:\temp\7z1604-dsc.msi"
                DependsOn = "[xRemoteFile]SevenZip"
            }

            }
        }

    if ($AllNodes.where({$_.role -eq 'MgmtNode'}).NodeName){

            node MgmtHostConfig {

            WindowsFeature TelnetClient
            {
                Ensure = "Present"
                Name = 'Telnet-Client'
            }

            }
        }


        if ($AllNodes.where({-not $_.role}).NodeName){
            node BaseConfig {

                WindowsFeature BITS
                {
                    Ensure = "Present"
                    Name = 'BITS'
                }
            }
        }
}




