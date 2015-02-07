<#
.SYNOPSIS
    Stop an Azure VM via automation feature
.DESCRIPTION
    Stop a single Virtual Machine.
.PARAMETER vmName
    Name of the virtual machine
.PARAMETER serviceName
    Name of the service
.EXAMPLE
    Stop-AzureVMWithAutomation.ps1 -vmName "testmachine1" `
        -serviceName`"testservice1"
#>



workflow Stop-AzureVMWithAutomation {

    Param (
        # The name of service to start
        [Parameter(Mandatory=$True)]
        [String]$serviceName,

        # The name of VM to start
        [Parameter(Mandatory=$True)]
        [String]$vmName,

        # Due to no support of day exclusion for an automation, add days
        # parameter to choice when this script should run
        [Parameter(Mandatory=$True)]
        [ValidateCount(0,7)]
        [Array]$runningDays
    )

    # Verbose setting
    $VerbosePreference = "Continue"

    # Build array of short day names
    $validDays = (new-object system.globalization.datetimeformatinfo).AbbreviatedDayNames

    # Validate user entry
    Foreach ($day in $runningDays) {
        if ($validDays -notcontains $day) {
            Write-Error "'$day' is an invalid abbreviated day, exit"
            return $false
        }
    }

    # Check if tash should run this day
    $today = Get-Date -format ddd
    if ($runningDays -notcontains $today) {
        Write-Output "'$today' is not a running day, exit"
        return $true
    } else {
        Write-Verbose "'$today' is a running day, continue"
    }

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
    Write-Verbose "Processing stop of $vmName ($serviceName)"
    Stop-AzureVM -ServiceName "$serviceName" -Name "$vmName" -Force
}
