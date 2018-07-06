<#
.SYNOPSIS
    By default this script removes unwanted columns and USB registry entries based on their device driver from TSV formatted USBDeview data.  It outputs a "clean" CSV file for futher spreadsheet analysis.  Yes, this is the same as manually deleting or hiding all those columns and manually filtering out all those device drivers.

.DESCRIPTION
    This script removes the following records that have these device drivers: acr3801.sys, cxbu0x64.sys, dlsusb.sys, hidusb.sys, idUsb.sys, LSCANUsbamd64.sys, usbccgp.sys, usbser.sys, WinUSB.SYS

    Optionally, if the -ExcludePrintersScanners switch is enabled it removes devices that have the following device drivers: usbprint.sys, usbscan.sys
    
    This script keeps the following USBDeview columns: Description, Device Type, Drive Letter, Serial Number, Last Plug/Unplug Date, VendorID, ProductID, Computer Name, Service Name, Service Description, Driver Filename, Device Class, Device Mfg, Driver Description

    This script removes the following USBDeview columns: Device Name, Connected, Safe To Unplug, Disabled, USB Hub, Created Date, Firmware Revision, USB Class, USB SubClass, USB Protocol, Hub / Port, Vendor Name, Product Name, ParentId Prefix, Friendly Name, Power, USB Version, Driver Version, Driver InfSection, Driver InfPath, Instance ID, Capabilities

.PARAMETER TsvData
    The name of the USBDeview TSV output file.
    
.PARAMETER ExcludePrintersScanners
    
    
.NOTES
    Version 1.0
    Sam Pursglove

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
               HelpMessage='Enabled this switch to also remove all driver records for printers and scanners')]
    [switch]$ExcludePrintersScanners
)

$TsvData = Import-Csv $TsvFile -Delimiter `t

Write-Output 'Removing records that use the following device drivers:`n'
Write-Output 'acr3801.sys (ACR3801 Smart Card Reader)'
Write-Output 'cxbu0x64.sys (OMNIKEY 3x21 Smart Card)'
Write-Output 'dlsusb.sys (Barcode Scanner Communication)'
Write-Output 'hidusb.sys (USB Human Interface Device)'
Write-Output 'idUsb.sys (L-1 Identity Solutions TP4101 Live Scan Biometric Device)'
Write-Output 'LSCANUsbamd64.sys (Cross Match Technologies USB Scanner)'
Write-Output 'usbccgp.sys (USB Composite Device)'
Write-Output 'usbser.sys (Motorola Symbol Bar Code Scanner)'
Write-Output 'WinUSB.SYS (Intermex Mobile Computer)'

if ($ExcludePrintersScanners) {
    Write-Output 'usbprint.sys (USB Printing Support)'
    Write-Output 'usbscan.sys (USB Scanners – CardScan 800c, HP, Fujitsu)'
    $removeDrivers = $TsvData | Where-Object { ($_.('Driver Filename') -notmatch "acr3801.sys|cxbu0x64.sys|dlsusb.sys|hidusb.sys|idUsb.sys|LSCANUsbamd64.sys|usbccgp.sys|usbser.sys|WinUSB.SYS|usbprint.sys|usbscan.sys") } 
} else {
    $removeDrivers = $TsvData | Where-Object { ($_.('Driver Filename') -notmatch "acr3801.sys|cxbu0x64.sys|dlsusb.sys|hidusb.sys|idUsb.sys|LSCANUsbamd64.sys|usbccgp.sys|usbser.sys|WinUSB.SYS") } 
}

Write-Ouput 'Removing the following columns from the USBDeview data:`n'
Write-Output 'Device Name'
Write-Output 'Connected'
Write-Output 'Safe To Unplug'
Write-Output 'Disabled'
Write-Output 'USB Hub'
Write-Output 'Created Date'
Write-Output 'Firmware Revision'
Write-Output 'USB Class'
Write-Output 'USB SubClass'
Write-Output 'USB Protocol'
Write-Output 'Hub / Port'
Write-Output 'Vendor Name'
Write-Output 'Product Name'
Write-Output 'ParentId Prefix'
Write-Output 'Friendly Name'
Write-Output 'Power'
Write-Output 'USB Version'
Write-Output 'Driver Version'
Write-Output 'Driver InfSection'
Write-Output 'Driver InfPath'
Write-Output 'Instance ID'
Write-Output 'Capabilities'

$removeColumns = $removeDrivers | Select-Object 'Description','Device Type','Drive Letter','Serial Number','Last Plug/Unplug Date','VendorID','ProductID','Computer Name','Service Name','Service Description','Driver Filename','Device Class','Device Mfg','Driver Description'

Write-Output 'Writing the cleaned USBDeview data to a CSV file'

$removeColumns | Export-Csv -Path USBDeview_So_Fresh_And_So_Clean.csv -NoTypeInformation

# TO DO: perform an automatic lookup for the VendorID and ProductID fields from the usb.ids list
# TO DO: remove the WUDFRd.sys driver if the 'Device Type' is 'Smart Card'