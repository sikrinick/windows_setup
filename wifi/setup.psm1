# WiFi

function Setup-Wifi {
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SSID,
        [Parameter(Mandatory=$true, Position=1)]
        [string]$Password
    )

    # Create the Wi-Fi profile XML content
    $ProfileXml = @"
        <?xml version="1.0"?>
        <WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
            <name>$SSID</name>
            <SSIDConfig>
                <SSID>
                    <name>$SSID</name>
                </SSID>
            </SSIDConfig>
            <connectionType>ESS</connectionType>
            <connectionMode>auto</connectionMode>
            <MSM>
                <security>
                    <authEncryption>
                        <authentication>WPA2PSK</authentication>
                        <encryption>AES</encryption>
                        <useOneX>false</useOneX>
                    </authEncryption>
                    <sharedKey>
                        <keyType>passPhrase</keyType>
                        <protected>false</protected>
                        <keyMaterial>$Password</keyMaterial>
                    </sharedKey>
                </security>
            </MSM>
        </WLANProfile>
    "@

    # Save the profile XML to a temporary file
    $TempProfilePath = [System.IO.Path]::GetTempFileName() + ".xml"
    Set-Content -Path $TempProfilePath -Value $ProfileXml

    # Remove profile with the same name, just in case
    netsh wlan delete profile "$SSID"

    # Add the Wi-Fi profile to the system
    netsh wlan add profile filename="$TempProfilePath"

    # Connect to the Wi-Fi network
    netsh wlan connect name="$SSID"

    # Clean up the temporary profile file
    Remove-Item -Path $TempProfilePath

    Write-Output "Connected to Wi-Fi network $SSID."
}