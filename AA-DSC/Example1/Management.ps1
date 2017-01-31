Configuration Management
{
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    $Version = $ConfigurationData.NonNodeData.Version
    $Node = $ConfigurationData.NonNodeData.Node
    $Features = $ConfigurationData.NonNodeData.FeatureList

    Node ($Node + $Version)
    {
        foreach ($Feature in $Features){
            WindowsFeature ($Feature + " - Feature")
            {
                Ensure = "Present"
                Name = $Feature
            }
        }
    }
}