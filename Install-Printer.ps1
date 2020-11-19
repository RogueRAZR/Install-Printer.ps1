<#PSScriptInfo
 
.VERSION 1.1
 
.GUID b7d7c2fc-3fc2-405f-bbd8-62775faf2ce0
 
.AUTHOR Kyle Mosley
 
.COMPANYNAME RazerSharp
 
.COPYRIGHT
 
.TAGS Windows AutoPilot
 
.LICENSEURI
 
.PROJECTURI
 
.ICONURI
 
.EXTERNALMODULEDEPENDENCIES
 
.REQUIREDSCRIPTS
 
.EXTERNALSCRIPTDEPENDENCIES
 
.RELEASENOTES
Version 1.0: Original published version.

#>

<#
.SYNOPSIS
Installs printer driver from URL, adds driver to driverstore, add printer port, and add printer with optional custom name.
 
GNU General Public License v3.0
 
 Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
 Everyone is permitted to copy and distribute verbatim copies
 of this license document, but changing it is not allowed.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
.DESCRIPTION
This script with download a printer drivre from the designated URL. It will install the drivers to the driver store, then it will add the printer port, and printer using the drivers downloaded from the URL.
.PARAMETER url
The URL parameter points to a file located at a web location. The url must point to the actual driver file.
.PARAMETER DlPath
The path for the driver download to be saved on your computer. (Optional) If left default driver will download to user downloads folder. 
.PARAMETER Driver
Name of the Driver as it should appear in the DriverStore.
.PARAMETER DriverZPath
Path to the INF file for the driver installation. This is the internal path of the .zip (The path to the .zip is appended automatically)
.PARAMETER PrintIP
The IP address or hostname of the printer port which should be added.
.PARAMETER PrinterName
Custom name for the printer to be added (Optional Parameter, if not provided the Printer will be added with the DriverStore name)
.PARAMETER Delete
Tells the script to delete the driver files after install. Helpful when running script while attended and you dont need to keep the drivers.
.PARAMETER ErrorActionPreferance
Defines what should happen in the case of an error. If script runs unattended (like in InTune), this should be left to SilentlyContinue. If debugging is needed change to Continue or Stop.

.EXAMPLE
.\Install-Printer.ps1 -url "https://cscsupportftp.mykonicaminolta.com/DownloadFile/Download.ashx?fileversionid=31329&productid=2175" -driver "KONICA MINOLTA C360i PCL Mono" -driverpath "\Driver\Drivers\PCL\EN\Win_x64\KOAXJJ__.inf" -printIP "192.168.10.110"

 
#>
param
(   
    [Parameter(Mandatory=$True)] [string] $url ="",
    [Parameter(Mandatory=$True)] [string] $Driver = "",
    [Parameter(Mandatory=$True)] [string] $DriverZPath = "",
    [Parameter(Mandatory=$True)] [string] $PrintIP = "",
    [Parameter(Mandatory=$False)] [string] $DlPath = $env:USERPROFILE + "\Downloads\PrinterDriver.zip",
    [Parameter(Mandatory=$False)] [string] $PrinterName = "",
    [Parameter(Mandatory=$False)] [switch] $Delete = $False,
    [Parameter(Mandatory=$False)] [string] $ErrorActionPreference = 'SilentlyContinue'
)
    

#Main Function (Starts download, starts extraction, calls driver installation, calls printer installation)
    function printermain {
        $DriverTest = Get-PrinterDriver -Name $Driver    
        Try 
        {   
            If ((-not (Test-Path $DlPath)) -and (-not ($DriverTest.Name.Contains($Driver))))
            {
                #Create Directory
                New-Item -Path $ZPath -ItemType Directory
                #Download printer driver (if it hasn't been already)
                Start-BitsTransfer -Source $url -Destination $DlPath
                #Extract printer driver
                Expand-Archive -Path $DlPath -DestinationPath $ZPath
                #Begin driver installation
                installdrivers
            }
            Else
            {
                Write-Output "Printer Driver is already installed, Continuing..."
            }
        }
        Catch 
        {
                Write-Output "Error Downloading, Extracting, or Installing the " $Driver " Package: " $_
        }
        #Checks if the printer has already been added, then calls the installprinter function if it hasn't
        $PrinterTest = Get-Printer -Name $PrinterName
        if (-not ($PrinterTest.Name -eq $PrinterName)) 
        {
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
        Try 
        {
            $DriverPath = $DlPath + $DriverZPath
            pnputil /add-driver $DriverPath
            Add-PrinterDriver -Name $Driver
        }
        Catch 
        {
            Write-Output "Problem adding driver to DriverStore: " $_
        }
    }

    #Installs the printer and sets the port
    function installprinter {
        Try 
        {
            Add-PrinterPort -Name $PrintIP -PrinterHostAddress $PrintIP
            Add-Printer -Name $PrinterName -DriverName $Driver -PortName $PrintIP
        }
        Catch 
        {
            Write-Output "Problem adding the Printer: " $_
        }
    }

    #Modify PrinterName a based on parameters
    If ($PrinterName -eq "")
    {
        $PrinterName = $driver
    }
    #Set zpath and call main then delete zpath.
    $ZPath = $DlPath -replace '\\\w+\.\w+'
    printermain
    #Removes the downloaded files automatically as long as DontDel is not set
    If ((Test-Path $ZPath) -and ($Delete -eq $True))
    {
        Remove-Item $ZPath -Recurse
    }
    Exit
