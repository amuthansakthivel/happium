# To use this script, open a powershell terminal with elevated access (as administrator).

# Then execute below commands.
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine

# ---------------------------------------------------------------------
# NOTE: This above first command is to allow powershell to import and run this module. Else you may get this error
# Import-Module: File D:\happium\install\Install-FullAppiumSetupOnWindows.psm1 cannot be loaded.
# The file D:\happium\install\Install-FullAppiumSetupOnWindows.psm1 is not digitally signed.
# You cannot run this script on the current system.
# For more information about running scripts and setting execution policy, see about_Execution_Policies
# at https://go.microsoft.com/fwlink/?LinkID=135170.
# ---------------------------------------------------------------------

# cd to this project. Say (cd D:\happium\)
# Import-Module .\install\Install-FullAppiumSetupOnWindows.psm1 -Force
# Install-FullAppiumSetupOnWindows

# Note: After full setup is complete, open a new powershell terminal as administrator to see all changed env variables and installed softwares.
function Install-FullAppiumSetupOnWindows {
    [CmdletBinding()]
    param(
        [Alias('os')]
        [String] $operatingSystem = 'windows'
    )
    # Install chocolatey (the awesome - windows package manager)
    Install-Chocolatey

    # Install open JDK8 (if already installed/upgraded; skips). 
    Install-OpenJDK8

    # Install or upgrade nodejs (if already installed/upgraded; skips). 
    Install-NodeJS

    # Install appium server and client (if already installed; skips) 
    Install-AppiumServerAndClient 

    # Install appium desktop (if already installed; skips) 
    Install-AppiumDesktop

    # Install appium doctor (if already installed; skips) 
    Install-AppiumDoctor

    # Install android studio (if already installed/upgraded; skips). 
    Install-AndroidStudio
}

# Tested okay [when node is installed or uninstalled].
function Install-Chocolatey {
    # https://chocolatey.org/install
    # If already installed, below step does not install it again and skips. 
    Get-ExecutionPolicy
    Set-ExecutionPolicy AllSigned
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    
    # upgrade chocolatey if already installed
    choco upgrade chocolatey
    choco -?
 }

# Tested okay [when node is installed or uninstalled].
function Install-OpenJDK8 {
    # If already installed or is at latest version, than it will not install/upgrade again. 
    choco install openjdk8
    choco upgrade openjdk8
 }

# Tested okay [when node is installed or uninstalled].
function Install-NodeJS {
    # If already installed or is at latest version, than it will not install/upgrade again. 
    choco install nodejs
    choco upgrade nodejs
 }

# Tested okay [when appium is installed or uninstalled].
function Install-AppiumServerAndClient {
    # Check if appium server is already installed. If not, install. Else skip. 
    $appiumVersion = appium --version | Select-String '.'
    If ($appiumVersion) {
        Write-Host "appium is already installed. Version: $appiumVersion"
    }else {
        # Install appium server 
        npm install -g appium
    }

    # Install appium client (webdriverio) - always- until I find a way to check version and skip if already installed.
    npm install wd
 }

 function Install-AppiumDesktop {
    # If already installed or is at latest version, than it will not install/upgrade again. 
    choco install appium-desktop
    choco upgrade appium-desktop
 }

 # Tested okay [when appium-doctor is installed or uninstalled].
function Install-AppiumDoctor {
    # Check if appium doctor is already installed. If not, install. Else skip. 
    $appiumDoctorVersion = appium-doctor --version | Select-String '.'
    If ($appiumDoctorVersion) {
        Write-Host "appium doctor is already installed. Version: $appiumDoctorVersion"
    }else {
        # Install appium-doctor
        npm install -g appium-doctor
    }
 }

 # Tested okay [when androidstudio is installed or uninstalled].
 function Install-AndroidStudio {
    # Install android studio (if you want to run some virtual emulators for testing and not just real devices)
    # This will also install sdk at the right location: C:\Users\your-user-name\AppData\Local\Android\Sdk\
    # Choco also sets env varibles and saves you the hassle of setting up env variables
    # if you only want to run using real devices than you dont need android studio but sdk will suffice
    # however in that case, you would need to setup the env varaibles though - so below setup is better.
    choco install androidstudio
    choco upgrade androidstudio

    # Set below properties at machine level; since eventually we want the sdk tools present in these folders to create emualtors from command line scripts (to automate the process) and not via android studio (manually)
    # Note: Running this command multiple times will NOT add the same path multiple times. So its completly safe to run this install script multiple times without having to worry about adding duplicate paths.
    [Environment]::SetEnvironmentVariable("Path", $env:Path + ";%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\tools;%ANDROID_HOME%\tools\bin", "Machine")
 }

 function Test-AppiumSetUp {
    # Verify the installation
    appium-doctor

    # todo: Add checks to take self healing actions if setup is not correct. 
}

# Uninstall in the reverse order of installation (so first installed item is the last to be uninstalled)
 function Uninstall-FullAppiumSetupFromWindows {
     # Uninstall android studio
     choco uninstall androidstudio

     # remove appium-doctor
     npm uninstall -g appium-doctor

     # Uninstall appium desktop
     choco uninstall appium-desktop

    # Uninstall appium server and client
     npm uninstall wd
    npm uninstall -g appium

    # nodejs (npm) work is done. Can uninstall now.
    choco uninstall nodejs

    # uninstall openjdk8
    choco uninstall openjdk8

    # In the end, if for some reasons,you want to uninstall chocolatey as well, 
    # follow these instructions. I would recommend not to install chocolatey though.
    # https://docs.chocolatey.org/en-us/choco/uninstallation
}