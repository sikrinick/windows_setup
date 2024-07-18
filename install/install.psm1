
# Returns process object
function Install-Chrome {
    $ChromeInstallProcess = Start-Process -FilePath "$PSScriptRoot\ChromeSetup.exe" -PassThru
    return $ChromeInstallProcess
}

# Returns process object
function Install-Office2021 {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$LanguageCode
    )

    $OfficeConfiguration = @"
<Configuration>
    <Add OfficeClientEdition="64">
        <Product ID="ProPlus2021Retail">
            <Language ID="$($LanguageCode)" />
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

    $officeInstallProcess = Start-Process -FilePath "$PSScriptRoot\Office2021Setup.exe" -ArgumentList "/configure `"$TempConfigurationPath`"" -PassThru

    return $officeInstallProcess
}