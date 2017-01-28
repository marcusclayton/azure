Configuration ItWorksParams
{
    param(
        [Parameter(Mandatory=$true)]
        [string] $FeatureName,

        [Parameter(Mandatory=$true)]
        [boolean] $IsPresent
    )
    
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    
    if(-not $IsPresent)
    {
        $EnsureString = "Absent"
    } else {
        $EnsureString = "Present"
    }

    Node Something
    {
        WindowsFeature ($FeatureName + "Feature")
        {
            Ensure = $EnsureString
            Name = $FeatureName
        }

        WindowsFeature ADRSAT
        {
            Ensure = "Present"
            Name = 'RSAT-AD-Tools'
        }
        
    }
}