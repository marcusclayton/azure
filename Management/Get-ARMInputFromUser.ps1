$location = 'southcentralus'
$i = 0
$images = Get-AzureRmVmSize -Location $location | where {($_.Name -match "DS") -and ($_.Name -match "_v2")}

$hash = $images | %{
    $hash = @{}
    $hash[$i] = ($_ | select name,@{l='NumCores';e={$_.NumberOfCores}},@{l="MemoryGB";e={$_.MemoryInMB/1024}})
    $hash
    $i++
}

$hash

Write-Host -NoNewline "Enter the index number of the VM Image to use: "  -ForegroundColor yellow; $index = read-host 

#Display the chosen location
$selection = $hash[$index].values.Name
Write-Host "Selected VM Image is: " $selection -ForegroundColor Green



#Now do something with the string $selection ....