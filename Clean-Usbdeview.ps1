<#
.SYNOPSIS
    By default this script removes unwanted columns and USB registry entries based on their device driver from TSV formatted NirSoft USBDeview data.  It outputs a "clean" CSV file for futher spreadsheet analysis.  Yes, this is the same as manually deleting or hiding all those columns and manually filtering out all those device drivers in spreadsheet software.
.DESCRIPTION
    This script removes the following records that have these device drivers: a38ccid.sys, acr3801.sys, amdhub30.sys, amdhub31.sys, cxbu0x64.sys, dlsusb.sys, hidusb.sys, idUsb.sys, iusb3hub.sys, LSCANUsbamd64.sys, usb8023x.sys, usbccgp.sys, usbser.sys, WinUSB.SYS.  It also removes records that have WUDFRd.sys driver and are smartcard related.

    Options exist to remove devices related to printing and scanning as well as to remove any unknown record type that has no device driver data.
    
    This script keeps the following USBDeview columns: Description, Device Type, Drive Letter, Serial Number, Last Plug/Unplug Date, VendorID, ProductID, Computer Name, Vendor Name, Service Name, Service Description, Driver Filename, Device Class, Device Mfg, Driver Description

    This script removes the following USBDeview columns: Device Name, Connected, Safe To Unplug, Disabled, USB Hub, Created Date, Firmware Revision, USB Class, USB SubClass, USB Protocol, Hub / Port, Product Name, ParentId Prefix, Friendly Name, Power, USB Version, Driver Version, Driver InfSection, Driver InfPath, Instance ID, Capabilities

    The cleaned USBDeview output file is called 'USBDeview_Cleaned_Output.csv'.
.PARAMETER TsvInputFile
    The file name of the USBDeview TSV output file.
.PARAMETER CsvOutputFile
    The file name of the cleaned USBDeview CSV output file (default: USBDeview_Cleaned_Output.csv)
.PARAMETER RemovePrintersScanners
    If this switch is used it removes records that contain the generic printer (Dot4.sys, usbprint.sys) and scan (usbscan.sys) drivers.
.PARAMETER RemoveNoDriver
    If this switch is used it removes unknown record types that contain no driver data.
.PARAMETER OldestDate
    Filters data from the cleaned output that has a 'Last Plug/Unplug Date' older than the specified value.  Input should be entered in the form of MM/DD/YYYY for US configured systems.  Note that this date information may not be accurate.  If the date is the same as when USBDeview was run this is likely the case.
.PARAMETER NewestDate
    Filters data from the cleaned output that has a 'Last Plug/Unplug Date' newer than the specified value.  Input should be entered in the form of MM/DD/YYYY for US configured systems.  Note that this date information may not be accurate.  If the date is the same as when USBDeview was run this is likely the case.
.NOTES
    Version 1.0
    Sam Pursglove
    Last Modified: 27 JUL 2018
.EXAMPLE
    Clean-Usbdeview.ps1 -TsvInputFile .\usbdeview_data.tsv

    Run the script with only the TSV input data.  The output file uses the default name of 'USBDeview_Cleaned_Output.csv'.
.EXAMPLE
    Clean-Usbdeview.ps1 -TsvInputfile .\usbdeview_data.tsv -CsvOutputFile cleanedUsbdeview.csv -RemoveNoDriver -RemovePrintersScanners

    Run the script with options to remove data with no driver listings for unknown devices and for known printer and scanners drivers.  Also to change the default output CSV file name to 'cleanedUsbdeview.csv'.
.EXAMPLE
    Clean-Usbdeview.ps1 -TsvInputfile .\usbdeview_data.tsv -OldestDate 02/01/2017 -NewestDate 07/31/2017

    Runs the script with the 
#>

Param 
(
    [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $false, HelpMessage = 'Filename of the USBDeview TSV output file.')]
    [string]
    $TsvInputFile,

    [Parameter(Position = 1, Mandatory = $false, ValueFromPipeline = $false, HelpMessage ='Filename of the cleaned USBDeview output CSV file.')]
    [string]
    $CsvOutputFile = "USBDeview_Cleaned_Output.csv",

    [Parameter(Mandatory = $false, ValueFromPipeline = $false, HelpMessage = 'Enable this switch to remove records related to generic printer and scanner drivers.')]
    [switch]
    $RemovePrintersScanners,
    
    [Parameter(Mandatory = $false, ValueFromPipeline = $false, HelpMessage = 'Enable this switch to remove unknown record types that have no driver data.')]
    [switch]
    $RemoveNoDriver,

    [Parameter(Mandatory = $false, ValueFromPipeline = $false, HelpMessage = 'Enter the date of the oldest record you wish to return in the MM/DD/YYYY format.')]
    [datetime]
    $OldestDate,

    [Parameter(Mandatory = $false, ValueFromPipeline = $false, HelpMessage = 'Enter the date of the newest record you wish to return in the MM/DD/YYYY format.')]
    [datetime]
    $NewestDate
)


$TsvData = Import-Csv $TsvInputFile -Delimiter `t


# remove columns with little-to-no analysis value from the default USBDeview output

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

$removeColumns = $TsvData | Select-Object 'Description','Device Type','Drive Letter','Serial Number','Last Plug/Unplug Date','VendorID','ProductID','Computer Name','Vendor Name','Service Name','Service Description','Driver Filename','Device Class','Device Mfg','Driver Description'


# remove devices with drivers that provide little-to-no analysis value

Write-Output `n'Removing records that use the following device drivers:'
Write-Output `t'a38ccid.sys'
Write-Output `t'acr3801.sys'
Write-Output `t'amdhub30.sys'
Write-Output `t'amdhub31.sys'
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

$removeDevices = $removeColumns | Where-Object { ($_.('Driver Filename') -notmatch "a38ccid.sys|acr3801.sys|amdhub30.sys|amdhub31.sys|cxbu0x64.sys|dlsusb.sys|hidusb.sys|idUsb.sys|iusb3hub.sys|LSCANUsbamd64.sys|usb8023x.sys|usbccgp.sys|usbser.sys|usbhub.sys|usbhub3.sys|WinUSB.SYS") } 


Write-Output `n'Removing smartcard related records with the WUDFRd.sys driver'

$removeDevices = $removeDevices | Where-Object { (($_.('Driver Filename') -notmatch "WUDFRd.sys") -or ($_.('Driver Filename') -match "WUDFRd.sys") -and ($_.('Device Type') -notmatch "Smart Card")) }

# optional switch to remove devices with known printer and scanner drivers
if ($RemovePrintersScanners) {
    
    Write-Output `n'Removing records related to printer and scanner drivers:'
    Write-Output `t'Dot4.sys'
    Write-Output `t'usbprint.sys'
    Write-Output `t'usbscan.sys'
    $removeDevices = $removeDevices | Where-Object { ($_.('Driver Filename') -notmatch "Dot4.sys|usbprint.sys|usbscan.sys") } 
}


# optional switch to remove devices that are unknown and have no driver data
if ($RemoveNoDriver) {
    
    Write-Output `n'Removing unknown records that have no driver data'
    $removeDevices = $removeDevices | Where-Object { !(($_.('Driver Filename').length -lt 1) -and ($_.('Device Type') -match "Unknown")) } 
}


# filter devices based on the date in the 'Last Plug/Unplug Date' field
if (($OldestDate -ne $null) -or ($NewestDate -ne $null)) {

    $removeDevices | ForEach-Object { 
    
            $_.'Last Plug/Unplug Date' -match "(?<Month>\d{1,2})/(?<Day>\d{1,2})/(?<Year>\d{4})" | Out-Null
            $_.'Last Plug/Unplug Date' = [datetime]"$($Matches.Month)/$($Matches.Day)/$($Matches.Year)"
        }

    # filter records that are older than a user specified date
    if ($OldestDate -ne $null) {
        
        Write-Output `n"Removing records with a 'Last Plug/Unplug Date' older than $($OldestDate.ToString().Split(' ')[0]) (note: time values are intentionally discarded)"
        $removeDevices = $removeDevices | Where-Object { $_.'Last Plug/Unplug Date' -ge $OldestDate }
    }

    # filter records that are newer than a user specified date
    if ($NewestDate -ne $null) {
        
        Write-Output `n"Removing records with a 'Last Plug/Unplug Date' newer than $($NewestDate.ToString().Split(' ')[0]) (note: time values are intentionally discarded)"
        $removeDevices = $removeDevices | Where-Object { $_.'Last Plug/Unplug Date' -le $NewestDate }
    }    
}


Write-Output `n'Writing the cleaned USBDeview data to a CSV file'

$removeDevices | Export-Csv -Path $CsvOutputFile -NoTypeInformation

# TO DO: perform an automatic lookup for the VendorID and ProductID fields from the usb.ids list