Configuration DownloadARMTemplate
{
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    Node $AllNodes.Where{$_.role -eq 'vstsWorker'}.NodeName
     {
        Service BITS
        {
            Name = "BITS"
            State = "Running"
            DependsOn = "[xRemoteFile]Random"
        }

        xRemoteFile Random {
            Uri = $NonNodeData.URL
            DestinationPath = $NonNodeData.packagePath
        }
    }

    Node $AllNodes.Where{$_.role -eq 'azureautomationhybridworker'}.NodeName
     {
        WindowsFeature Telnet
        {
            Name = "Telnet-Client"
            Ensure = "Present"
        }

        xRemoteFile Random {
            Uri = $NonNodeData.URL
            DestinationPath = $NonNodeData.Path
        }
    }

}