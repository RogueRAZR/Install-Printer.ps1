#Parameters    
    $url = "<Driver File URL>"
    $dlpath = "<File Download Destination and Filename>"
    $zpath = "<UnZip Output Path> (Optional)"
    $driver = "<Printer DriverStore Name>"
    $driverpath = $zpath + "<Internal Path of extracted driver inf>"
    $printIP = "<Printer IP Address>"
    $PrinterName = "<Printer Dispaly Name (Optional)>"
    $ErrorActionPreference = 'SilentlyContinue'


#Main Function (Starts download, starts extraction, calls driver installation, calls printer installation)
function printermain {
    Try {                 
        If (-not (Test-Path $dlpath)) {
            #Download printer driver (if it hasn't been already)
            Start-BitsTransfer -Source $url -Destination $dlpath
        }
        #Extract printer driver
        If (($zpath -eq "") -or ($zpath -eq"<UnZip Output Path> (Optional)"))
        {
            $zpath = $dlpath -replace '\\\w+\.\w+'
            Expand-Archive -Path $dlpath -DestinationPath $zpath
        }
        Else
        {
            Expand-Archive -Path $dlpath -DestinationPath $zpath
        }
    }
    Catch {
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
    If (($PrinterName -eq "") -or ($PrinterName -eq "<Printer Dispaly Name (Optional)>"))
    {
        $PrinterName = $driver
    }
    $PrinterTest = Get-Printer -Name $PrinterName
    if (-not ($PrinterTest.Name = $PrinterName)) {
        installprinter
    }
    Else
    {
    Write-Output "Printer is already installed, Exiting..."
    Exit
    }
}

#Installs the printer driver
function installdrivers {
    Try {
        pnputil /add-driver $driverpath
    }
    Catch {
        Write-Output "Problem adding driver to DriverStore: " $_
    }
}

#Installs the printer
function installprinter {
    Try {
        Add-PrinterPort -Name $printIP -PrinterHostAddress $printIP
        Add-PrinterDriver -Name $driver
        Add-Printer -Name $PrinterName -DriverName $driver -PortName $printIP
    }
    Catch {
        Write-Output "Problem adding the Printer: " $_
    }
}

#Call main then delete extracted printer files.
printermain
If (Test-Path $zpath) {
    Remove-Item $zpath -Recurse
}
Exit
