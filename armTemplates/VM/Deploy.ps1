$secret = Get-AzureKeyVaultSecret -VaultName temp -SecretName adminpasswd
$TemplateURI = "https://raw.githubusercontent.com/marcusclayton/azure/master/armTemplates/VM/azuredeploy.json"
$resourceGroup = "armkeyvaulttest001"
$resourceGroupLocation = "West US"
$backupPolicy = (Get-AzureRmRecoveryServicesBackupProtectionPolicy).Name | out-gridview -title "Select a Backup Protection Policy..." -PassThru

$Params = @{
    pipvm001DnsName = "mcautodev04747" ;
    uniqueprefix = "1432vms";
    myvm001Name = "vm-dev-0001";
    myvm001AdminUserName = "marcus";
    myvm001WindowsOSVersion = "2016-Datacenter-with-Containers";
    adminpasswd = $secret.SecretValue ;
    tagCostCenter = "IT" ;
    VMBackupPolicy = $backupPolicy ;
}

$rg = New-AzureRmResourceGroup -Name $Params.rg -Location $Params.rgLocation -Verbose -Force -ErrorAction Stop

$deployment = New-AzureRmResourceGroupDeployment -Name "AzureDeployment-$(get-date -Format "yyyy-dd-mm-hh-mm-ss")" -Mode Incremental -TemplateParameterObject $Params -ResourceGroupName $resourceGroup -TemplateUri $TemplateURI -ErrorVariable deploymentError -Verbose -Force