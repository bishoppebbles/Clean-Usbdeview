# Clean-Usbdeview

## Running USBDeview

This is a script to remove unwanted USB devices and data fields from the TSV output of the [NirSoft USBDeview software](https://www.nirsoft.net/utils/usb_devices_view.html).

The USBDeview documentation has many command line options.  This is the commandprompt options I primarily use when running this program (note: things between the < > need to be your actual files):

```
.\USBDeview.exe /remotefile <targets.txt> /stab <usbdeview_data.tsv> /AddExportHeaderLine 1 /DisplayNoDriver 1 /DisplayHubs 1
```

* /remotefile : specifies the text file of systems to pull USB data from (generated from Hyena)
* /stab : save the list of all USB device data into a tab-delimited (TSV) file
* /AddExportHeaderLine : adds a header line to the tab-delimited (TSV) file
* /DisplayNoDriver : shows devices without a driver
* /DisplayHubs : shows USB hubs

## Running Clean-Usbdeview.ps1

This script takes the collected USBDeview data and removes (in my opinion) all the unnecessary devices and columns for faster analysis.  Again, this is the same as if you opened the USBDeview output in Excel and manually removed all of those things.  I realized that focusing on device drivers was the most consistent way to get rid of all the ‘noise’ with USBDeview.

When you run the script it tells you exactly what it’s removing.  First, devices with a given driver and then the columns.  You can edit that if you want to keep something in particular.

During testing I’ve compared the output of the script and with manual analysis of the same data in Excel and based on this the script results matched the manual analysis cleaning.  In general, the ‘cleaned’ output is keeping USB storage devices, printers, cameras, scanners, and any other uncommon drivers.  It’s removing drivers for USB hubs, mice, keyboards, composite devices, and card readers.

**Example (basic usage):**
```powershell
.\Clean-Usbdeview.ps1 -TsvInputFile .\usbdeview_data.tsv
```

**Output file:** \
USBDeview_Cleaned_Output.csv

After running the script you will still need to open the "cleaned" CSV file in a Spreadsheet editor and finish any final USBDeview analysis as before, but hopefully it's faster.

## Switch options

Switches can be run independently or at the same time.

### -OutputCsvFile
Allows you to output a CSV filename of your choosing (e.g., Contoso_USBDeview_Data.csv) instead of using the hardcoded default (i.e., USBDeview_Cleaned_Output.csv):

```powershell
.\Clean-Usbdeview.ps1 –InputTsvFile usbdeview_data.tsv –OutputCsvFile Contoso_USBDeview_Data.csv
```

### -RemovePrintersScanners
Removes some known printer and scanner device drivers.  If you don’t want those results use this option.

```powershell
.\Clean-Usbdeview.ps1 -TsvInputFile .\usbdeview_data.tsv -RemovePrintersScanners
```

### -RemoveNoDriver
This removes devices that have no driver listing and have an unknown device type.  I’m not sure why this occurs but I’ve consistently seen some for every USBDeview collect and those devices usually have very little data, and thus, very little value.

```powershell
.\Clean-Usbdeview.ps1 -TsvInputFile .\usbdeview_data.tsv -RemoveNoDriver
```

You may have noticed that this switch is a little weird as I suggested earlier to run USBDeview and use an option switch to explicitly collect devices with no driver -> ```/DisplayNoDriver 1```.  My thought process here is the data is there if you want it but I haven’t found any value in it so I prefer to remove it.  But you never know, there could be something of use.

I’m actually doing the same thing with USB hubs but that’s automatic.  I am telling USBDeview to collect hub information with ```/DisplayHubs 1``` but this script is automatically removing those drivers in the code.  As far as I know the hub drivers’ existence (there are several) really provide no value as we're looking for actual USB devices.  The results higher up the USB driver stack are what actually tell us about devices of interest.

### –OldestDate, –NewestDate

Allows you to filter the results based on the dates of the 'Last Plug/Unplug Date' column.  This is the same as if you used the filter function in Excel and unchecked the boxes next to the month/day/year that you wanted to remove.  You can filter the dates based on the oldest record(s) you want returned, the newest record(s) you want returned, or a combination of the two.  The input format should be in MM/DD/YYYY.

If you only want entries within the last year (since 26 JUL 2017) you could do this:

```powershell
.\Clean-Usbdeview.ps1 –InputTsvFile usbdeview_data.tsv –OldestDate 7/26/2017
```

If you only wanted results from February to April 2018 you could do this:

```powershell
.\Clean-Usbdeview.ps1 –InputTsvFile usbdeview_data.tsv –OldestDate 2/1/2018 –NewestDate 4/30/2018
```
