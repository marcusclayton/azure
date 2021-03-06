#$secret = Get-AzureKeyVaultSecret -VaultName temp -SecretName adminpasswd
$vault = (Get-AzureRmKeyVault) | select VaultName,ResourceGroupName,Tags | Out-GridView -Title "Select a Key Vault..." -PassThru
$secret = (Get-AzureKeyVaultSecret -VaultName $vault.VaultName) | select Name,VaultName,Version,Tags | Out-GridView -Title "Select a Secret..." -PassThru
$TemplateURI = "https://raw.githubusercontent.com/marcusclayton/azure/master/armTemplates/VM/VM2/keyvault.json"
$resourceGroup = "armkeyvaulttest001"
$resourceGroupLocation = "West US"
$recoveryVault = (Get-AzureRmRecoveryServicesVault) | Out-GridView -Title "Select a Recovery Services Vault..." -PassThru
Set-AzureRmRecoveryServicesVaultContext -Vault $recoveryVault -Verbose
$backupPolicy = Get-AzureRmRecoveryServicesBackupProtectionPolicy | out-gridview -title "Select a Backup Protection Policy..." -PassThru

$Params = @{
    vaultName = $vault.vaultName ;
    secretName = $secret.name ;
    keyVaultResourceGroup = $vault.ResourceGroupName ;
    pipvm001DnsName = "mcautodev04747" ;
    uniqueprefix = "1432vms";
    myvm001Name = "vm-dev-0001";
    myvm001AdminUserName = "marcus";
    myvm001WindowsOSVersion = "2016-Datacenter-with-Containers";
    VMBackupPolicy = $backupPolicy.name ;
    tagCostCenter = "IT";
}

$rg = New-AzureRmResourceGroup -Name $resourceGroup -Location $resourceGroupLocation -Verbose -Force -ErrorAction Stop

$deployment = New-AzureRmResourceGroupDeployment -Name "AzureDeployment-$(get-date -Format "yyyy-dd-mm-hh-mm-ss")" -Mode Incremental -TemplateParameterObject $Params -ResourceGroupName $resourceGroup -TemplateUri $TemplateURI -ErrorVariable deploymentError -Verbose -Force
$vm = get-azurermvm -ResourceGroupName $resourceGroup -Name $Params.myvm001name
$enableVMBackup = Enable-AzureRmRecoveryServicesBackupProtection -Policy $backupPolicy -Name $vm.name -ResourceGroupName $resourceGroup -Verbose
$namedContainer = Get-AzureRmRecoveryServicesBackupContainer -ContainerType "AzureVM" -Status "Registered" -FriendlyName $vm.name
$item = Get-AzureRmRecoveryServicesBackupItem -Container $namedContainer -WorkloadType "AzureVM"
$job = Backup-AzureRmRecoveryServicesBackupItem -Item $item -Verbose
$joblist = Get-AzureRmRecoveryservicesBackupJob –Status InProgress
$joblist[0]


