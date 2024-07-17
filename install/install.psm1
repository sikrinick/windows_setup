
# Returns process object
function Install-Chrome {
    # Set the script's directory as the current directory
    Push-Location -Path (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

    $chromeSetupPath = Join-Path -Path $PWD -ChildPath "ChromeSetup.exe"
    $chromeInstallProcess = Start-Process -FilePath $chromeSetupPath -PassThru

    return $chromeInstallProcess
}

function Install-Office2021 {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$LanguageCode
    )

    # Set the script's directory as the current directory
    Push-Location -Path (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

    $OfficeConfiguration = @"
        <Configuration>
            <Add OfficeClientEdition="64">
                <Product ID="ProPlus2021Retail">
                <Language ID=$LanguageCode />
                <ExcludeApp ID="Lync" />
                <ExcludeApp ID="Teams" />
                <ExcludeApp ID="Access" />
                <ExcludeApp ID="OneDrive" />
                <ExcludeApp ID="OneNote" />
                <ExcludeApp ID="Outlook" />
                <ExcludeApp ID="Publisher" />
                </Product>
            </Add>
            <Property Name="FORCEAPPSHUTDOWN" Value="TRUE" />
            <Display Level="Full" AcceptEULA="TRUE" />
            <Updates Enabled="TRUE" />
            <RemoveMSI />
        </Configuration>
    "@

    # Save the profile XML to a temporary file
    $TempConfigurationPath = [System.IO.Path]::GetTempFileName() + ".xml"
    Set-Content -Path $TempConfigurationPath -Value $OfficeConfiguration

    $officeInstallProcess = Start-Process -FilePath "Office2021Setup.exe" -ArgumentList "/configure `"$TempConfigurationPath`"" -PassThru
    
    # Return to the original directory
    Pop-Location

    return $officeInstallProcess
}