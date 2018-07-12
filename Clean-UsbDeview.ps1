<#
.SYNOPSIS
    By default this script removes unwanted columns and USB registry entries based on their device driver from TSV formatted NirSoft USBDeview data.  It outputs a "clean" CSV file for futher spreadsheet analysis.  Yes, this is the same as manually deleting or hiding all those columns and manually filtering out all those device drivers in spreadsheet software.
.DESCRIPTION
    This script removes the following records that have these device drivers: a38ccid.sys, acr3801.sys, amdhub30.sys, cxbu0x64.sys, dlsusb.sys, hidusb.sys, idUsb.sys, iusb3hub.sys, LSCANUsbamd64.sys, usb8023x.sys, usbccgp.sys, usbser.sys, WinUSB.SYS.  It also removes records that have WUDFRd.sys driver and are smartcard related.

    Options exist to remove devices related to printing and scanning as well as to remove any unknown record type that has no device driver data.
    
    This script keeps the following USBDeview columns: Description, Device Type, Drive Letter, Serial Number, Last Plug/Unplug Date, VendorID, ProductID, Computer Name, Vendor Name, Service Name, Service Description, Driver Filename, Device Class, Device Mfg, Driver Description

    This script removes the following USBDeview columns: Device Name, Connected, Safe To Unplug, Disabled, USB Hub, Created Date, Firmware Revision, USB Class, USB SubClass, USB Protocol, Hub / Port, Product Name, ParentId Prefix, Friendly Name, Power, USB Version, Driver Version, Driver InfSection, Driver InfPath, Instance ID, Capabilities

    The cleaned USBDeview output file is called 'USBDeview_So_Fresh_And_So_Clean_Clean.csv'.
.PARAMETER TsvData
    The name of the USBDeview TSV output file.
.PARAMETER RemovePrintersScanners
    If this switch is used it removes records that contain the generic printer (Dot4.sys, usbprint.sys) and scan (usbscan.sys) drivers.
.PARAMETER RemoveNoDriver
    If this switch is used it removes unknown record types that contain no driver data.
.NOTES
    Version 1.0
    Sam Pursglove
    Last Modified: 11 JUL 2018
.EXAMPLE
    Clean-UsbDeview.ps1 .\usbdeview_data.tsv
#>

Param 
(
    [Parameter(Position=0,
               Mandatory=$true,
               ValueFromPipeline=$false,
               HelpMessage='Filename of the USBDeview TSV output file.')]
    [string]$TsvFile,

    [Parameter(Mandatory=$false,
               ValueFromPipeline=$false,
               HelpMessage='Enable this switch to remove records related to generic printer and scanner drivers.')]
    [switch]$RemovePrintersScanners,
    
    [Parameter(Mandatory=$false,
               ValueFromPipeline=$false,
               HelpMessage='Enable this switch to remove unknown record types that have no driver data.')]
    [switch]$RemoveNoDriver
)

$TsvData = Import-Csv $TsvFile -Delimiter `t

Write-Output `n'Removing records that use the following device drivers:'
Write-Output `t'a38ccid.sys'
Write-Output `t'acr3801.sys'
Write-Output `t'amdhub30.sys'
Write-Output `t'cxbu0x64.sys'
Write-Output `t'dlsusb.sys'
Write-Output `t'hidusb.sys'
Write-Output `t'idUsb.sys'
Write-Output `t'iusb3hub.sys'
Write-Output `t'LSCANUsbamd64.sys'
Write-Output `t'usb8023x.sys'
Write-Output `t'usbccgp.sys'
Write-Output `t'usbser.sys'
Write-Output `t'usbhub.sys'
Write-Output `t'UsbHub3.sys'
Write-Output `t'WinUSB.SYS'

$removeDrivers = $TsvData | Where-Object { ($_.('Driver Filename') -notmatch "a38ccid.sys|acr3801.sys|amdhub30.sys|cxbu0x64.sys|dlsusb.sys|hidusb.sys|idUsb.sys|iusb3hub.sys|LSCANUsbamd64.sys|usb8023x.sys|usbccgp.sys|usbser.sys|usbhub.sys|usbhub3.sys|WinUSB.SYS") } 


Write-Output `n'Removing smartcard related records with the WUDFRd.sys driver'

$removeDrivers = $removeDrivers | Where-Object { (($_.('Driver Filename') -notmatch "WUDFRd.sys") -or ($_.('Driver Filename') -match "WUDFRd.sys") -and ($_.('Device Type') -notmatch "Smart Card")) }


if ($RemovePrintersScanners) {
    Write-Output `n'Removing records related to printer and scanner drivers:'
    Write-Output `t'Dot4.sys'
    Write-Output `t'usbprint.sys'
    Write-Output `t'usbscan.sys'
    $removeDrivers = $removeDrivers | Where-Object { ($_.('Driver Filename') -notmatch "Dot4.sys|usbprint.sys|usbscan.sys") } 
}


if ($RemoveNoDriver) {
    Write-Output `n'Removing unknown records that have no driver data'
    $removeDrivers = $removeDrivers | Where-Object { (($_.('Driver Filename').length -gt 0) -or ($_.('Device Type') -notmatch "Unknown")) } 
}


Write-Output `n'Removing the following columns from the USBDeview data:'
Write-Output `t'Device Name'
Write-Output `t'Connected'
Write-Output `t'Safe To Unplug'
Write-Output `t'Disabled'
Write-Output `t'USB Hub'
Write-Output `t'Created Date'
Write-Output `t'Firmware Revision'
Write-Output `t'USB Class'
Write-Output `t'USB SubClass'
Write-Output `t'USB Protocol'
Write-Output `t'Hub / Port'
Write-Output `t'Product Name'
Write-Output `t'ParentId Prefix'
Write-Output `t'Friendly Name'
Write-Output `t'Power'
Write-Output `t'USB Version'
Write-Output `t'Driver Version'
Write-Output `t'Driver InfSection'
Write-Output `t'Driver InfPath'
Write-Output `t'Instance ID'
Write-Output `t'Capabilities'

$removeColumns = $removeDrivers | Select-Object 'Description','Device Type','Drive Letter','Serial Number','Last Plug/Unplug Date','VendorID','ProductID','Computer Name','Vendor Name','Service Name','Service Description','Driver Filename','Device Class','Device Mfg','Driver Description'

Write-Output `n'Writing the cleaned USBDeview data to a CSV file'

$removeColumns | Export-Csv -Path USBDeview_So_Fresh_And_So_Clean_Clean.csv -NoTypeInformation

# TO DO: perform an automatic lookup for the VendorID and ProductID fields from the usb.ids list