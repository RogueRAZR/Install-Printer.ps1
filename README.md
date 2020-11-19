# Install-Printer.ps1
Script which downloads, installs, and sets up network printers

Parameters:

$url: Set this to the URL for downloading the Driver. Needs to point to the actual zip file. (Required)

$dlpath: Sets the download file location for your drivers (Required)

$driver: This needs to be set to the DriverStore Name of the Driver. (Required)

$driverpath: This needs the pathing to the driver INF file. It appends your zip path automatically. (Required)

$printIP: This is the hostname/IP address of the printer you are installing (Required)

$PrinterName: Set this to customize the name of the printer, set blank to make printer name same as DriverStore Name. (Optional)

$ErrorActionPreference: Tells the Try/Catch functions what to do if there is an error, recommended to leave as Continue if installing unattended. Set to "Continue" or "Inquire" if you are having issues and want to see errors. 


Use this script for mass deploying printers using an MDM like InTune.


EXAMPLE PARAMETERS:
$url = "https://cscsupportftp.mykonicaminolta.com/DownloadFile/Download.ashx?fileversionid=31329&productid=2175"

$dlpath = "C:\Drivers"

$driver = "KONICA MINOLTA C360i PCL Mono"

$driverpath = $zpath + "\Driver\Drivers\PCL\EN\Win_x64\KOAXJJ__.inf"

$printIP = "192.168.0.5"

$PrinterName = ""

$ErrorActionPreference = 'ContinueSilently'

This example with install drivers for a Konica Minolta bizhub C360i. Then it will install the printer with port 192.168.0.5 and the name of the printer will be "KONICA MINOLTA C360i PCL Mono"
