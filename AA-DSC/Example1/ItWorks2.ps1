Configuration ItWorks2
{
    
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    Write-Verbose $ConfigurationData.NonNodeData.SomeMessage
    

    Node $AllNodes.Where{$_.Role -eq "TestBox"}.NodeName
    {
        WindowsFeature ($Node.Feature + "Feature")
        {
            Ensure = "Present"
            Name = $Node.Feature
        }

        WindowsFeature ADRSAT
        {
            Ensure = "Present"
            Name = 'RSAT-AD-Tools'
        }
        
    }
}