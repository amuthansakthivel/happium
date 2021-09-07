# To use this script, open a powershell terminal with elevated access (as administrator).

# Then execute below commands.
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine

# cd to this project. Say (cd D:\happium\)
# Import-Module .\install\Start-AppiumServer.psm1 -Force
# [To run in the same terminal]
    # Start-AppiumServer
# [To run as a background Job]
# Start-AppiumServer -asBackgroundJob

# To run server as background. Run below command. By default, it runs the server in the current terminal.
function Start-AppiumServer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [Switch]$asBackgroundJob
    )

    # Remove any previously open appium background instances that may prevent from starting a new instance
    Stop-AppiumServer

    # start appium
    If ($asBackgroundJob.IsPresent) {
        Write-Host "starting appium server as a background job. Do `Stop-Job -Name Job1` to stop the background job."
        $appiumJob = Start-Job -ScriptBlock {appium}

        # Verify if appium is running or not (since in background mode, you dont see it running)
        $appiumJob
        Test-AppiumServer
    }else {
        Write-Host "starting appium server in the current terminal. Do ctrl +c to close the server."
        appium
    }
 }

 function Stop-AppiumServer {
    # Get all running jobs
    Get-Job

    # Stop all running background jobs (dont worry, there are no background jobs except the one we created)
    Get-Job | Stop-Job

    # Remove all running background jobs
    Get-Job | Remove-Job

    # Verify that the server is stopped and all background jobs are removed.
    Get-Job
 }

 function Test-AppiumServer {
    # Verify if appium is running or not
    curl http://127.0.0.1:4723/wd/hub/status
 }