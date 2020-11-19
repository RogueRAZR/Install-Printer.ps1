#Parameters    
    $url = "<Driver File URL>"
    $dlpath = "<File Download Destination and Filename>"
    $driver = "<Printer DriverStore Name>"
    $driverpath = $zpath + "<Internal Path of extracted driver inf>"
    $printIP = "<Printer IP Address>"
    $PrinterName = "<Printer Dispaly Name (Optional)>"
    $ErrorActionPreference = 'SilentlyContinue'


#Main Function (Starts download, starts extraction, calls driver installation, calls printer installation)
function printermain {
    Try 
    {                 
        If (-not (Test-Path $dlpath)) 
        {
            #Create Directory
            New-Item -Path $zpath -ItemType Directory
            #Download printer driver (if it hasn't been already)
            Start-BitsTransfer -Source $url -Destination $dlpath
        }
        #Extract printer driver
        Expand-Archive -Path $dlpath -DestinationPath $zpath
    }
    Catch 
    {
            Write-Output "Error Downloading and Extracting " $driver " Package: " $_
    }
    $DriverTest = Get-PrinterDriver -Name $driver
    If (-not ($DriverTest.Name.Contains($driver))) 
    {
        installdrivers
    }
    Else
    {
    Write-Output "Printer Driver is already installed, Continuing..."
    }
    $PrinterTest = Get-Printer -Name $PrinterName
    if (-not ($PrinterTest.Name -eq $PrinterName)) {
        installprinter
    }
    Else
    {
    Write-Output "Printer is already installed, Exiting..."
    Exit
    }
}

#Installs the printer driver
function installdrivers 
{
    Try 
    {
        pnputil /add-driver $driverpath
    }
    Catch 
    {
        Write-Output "Problem adding driver to DriverStore: " $_
    }
}

#Installs the printer
function installprinter 
{
    Try 
    {
        Add-PrinterPort -Name $printIP -PrinterHostAddress $printIP
        Add-PrinterDriver -Name $driver
        Add-Printer -Name $PrinterName -DriverName $driver -PortName $printIP
    }
    Catch 
    {
        Write-Output "Problem adding the Printer: " $_
    }
}

#Modify PrinterName based on parameters
If (($PrinterName -eq "") -or ($PrinterName -eq "<Printer Dispaly Name (Optional)>"))
{
    $PrinterName = $driver
}
#Set zpath and call main then delete zpath.
$zpath = $dlpath -replace '\\\w+\.\w+'
printermain
If (Test-Path $zpath) 
{
    Remove-Item $zpath -Recurse
}
Exit
