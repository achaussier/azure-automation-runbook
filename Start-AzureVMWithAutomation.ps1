<#
.SYNOPSIS
    Start an Azure VM via automation feature
.DESCRIPTION
    Start a single Virtual Machine.
.PARAMETER vmName
    Name of the virtual machine
.PARAMETER serviceName
    Name of the service
.EXAMPLE
    Start-AzureVMWithAutomation.ps1 -vmName "testmachine1" `
        -serviceName`"testservice1"
#>

workflow Start-AzureVMWithAutomation {

    Param (
        # The name of service to start
        [Parameter(Mandatory=$True)]
        [String]$serviceName,

        # The name of VM to start
        [Parameter(Mandatory=$True)]
        [String]$vmName
    )

    # Verbose setting
    $VerbosePreference = "Continue"

    # Get subscription informations for automation
    $subscriptionName = Get-AutomationVariable -Name "SubscriptionName"
    $subscriptionID = Get-AutomationVariable -Name "SubscriptionID"
    $certificateName = Get-AutomationVariable -Name "CertificateName"
    $certificate = Get-AutomationCertificate -Name $certificateName
    Write-Verbose "Using certificate $certificateName for $subscriptionName"

    # Set subscription with automation informations
    Set-AzureSubscription -SubscriptionName $subscriptionName `
        -SubscriptionId $subscriptionID -Certificate $certificate
    Select-AzureSubscription $subscriptionName

    # Start the VM
    Write-Verbose "Processing start of $vmName ($serviceName)"
    Start-AzureVM -ServiceName "$serviceName" -Name "$vmName"
}
