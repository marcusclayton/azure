$vault = (Get-AzureRmKeyVault) | select VaultName,ResourceGroupName,Tags | Out-GridView -Title "Select a Key Vault..." -PassThru
$secret = (Get-AzureKeyVaultSecret -VaultName $vault.VaultName) | select Name,VaultName,Version,Tags,SecretValue | Out-GridView -Title "Select a Secret..." -PassThru
$secret = Get-AzureKeyVaultSecret -Name $secret.Name -VaultName $secret.VaultName
$TemplateURI = "https://raw.githubusercontent.com/marcusclayton/azure/master/armTemplates/VM/azuredeploy.json"
$resourceGroup = "armkeyvaulttest001"
$resourceGroupLocation = "West US"
$recoveryVault = (Get-AzureRmRecoveryServicesVault) | Out-GridView -Title "Select a Recovery Services Vault..." -PassThru
Set-AzureRmRecoveryServicesVaultContext -Vault $recoveryVault -Verbose
$backupPolicy = Get-AzureRmRecoveryServicesBackupProtectionPolicy | out-gridview -title "Select a Backup Protection Policy..." -PassThru

$Params = @{
    pipvm001DnsName = "mcautodev04747" ;
    uniqueprefix = "1432vms";
    myvm001Name = "vm-dev-0001";
    myvm001AdminUserName = "marcus";
    myvm001WindowsOSVersion = "2016-Datacenter-with-Containers";
    VMBackupPolicy = $backupPolicy.Name ;
    adminpasswd = $secret.SecretValue ;
    tagCostCenter = "IT";
}

$rg = New-AzureRmResourceGroup -Name $resourceGroup -Location $resourceGroupLocation -Verbose -Force -ErrorAction Stop

$deployment = New-AzureRmResourceGroupDeployment -Name "AzureDeployment-$(get-date -Format "yyyy-dd-mm-hh-mm-ss")" -Mode Incremental -TemplateParameterObject $Params -ResourceGroupName $resourceGroup -TemplateUri $TemplateURI -ErrorVariable deploymentError -Verbose -Force
