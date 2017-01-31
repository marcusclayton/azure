Configuration TPGManagement
{   
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    $features = $ConfigurationData.NonNodeData.Features

    Node Mgmt2
    {
        foreach ($feature in $features){
            WindowsFeature ($feature + "Feature")
            {
                Ensure = "Present"
                Name = $feature
            }
        }
    }   
}