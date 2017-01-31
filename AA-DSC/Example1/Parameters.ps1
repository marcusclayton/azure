Configuration Parameters
{
    param(
        [Parameter(Mandatory=$true)]
        [string] $Version,
        [Parameter(Mandatory=$true)]
        [string] $Node,
        [Parameter(Mandatory=$true)]
        [string[]] $FeatureList
    )



    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    Node ($Node + $Version)
    {
        foreach ($Feature in $FeatureList){
            WindowsFeature ($Feature + " - Feature")
            {
                Ensure = "Present"
                Name = $Feature
            }
        }
    }
}