# WiFi

function Get-WifiAdapter {
    Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object {
        $_.PhysicalMediaType -eq 'Native 802.11' -or
        $_.InterfaceDescription -match 'Wireless|Wi-Fi|WLAN'
    } | Select-Object -First 1
}

function Enable-WifiRadio {
    # Turns the Wi-Fi radio on (covers airplane mode / soft kill switch).
    Try {
        Add-Type -AssemblyName System.Runtime.WindowsRuntime -ErrorAction Stop

        $asTaskGeneric = [System.WindowsRuntimeSystemExtensions].GetMethods() |
            Where-Object {
                $_.Name -eq 'AsTask' -and
                $_.GetParameters().Count -eq 1 -and
                $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'
            } | Select-Object -First 1

        function Await($op, $resultType) {
            $task = $asTaskGeneric.MakeGenericMethod($resultType).Invoke($null, @($op))
            $task.Wait(-1) | Out-Null
            $task.Result
        }

        [Windows.Devices.Radios.Radio,Windows.Devices.Radios,ContentType=WindowsRuntime] | Out-Null
        [Windows.Devices.Radios.RadioAccessStatus,Windows.Devices.Radios,ContentType=WindowsRuntime] | Out-Null
        [Windows.Devices.Radios.RadioState,Windows.Devices.Radios,ContentType=WindowsRuntime] | Out-Null

        Await ([Windows.Devices.Radios.Radio]::RequestAccessAsync()) ([Windows.Devices.Radios.RadioAccessStatus]) | Out-Null
        $radios = Await ([Windows.Devices.Radios.Radio]::GetRadiosAsync()) ([System.Collections.Generic.IReadOnlyList[Windows.Devices.Radios.Radio]])

        foreach ($r in $radios) {
            if ($r.Kind -eq [Windows.Devices.Radios.RadioKind]::WiFi -and $r.State -ne [Windows.Devices.Radios.RadioState]::On) {
                Await ($r.SetStateAsync([Windows.Devices.Radios.RadioState]::On)) ([Windows.Devices.Radios.RadioAccessStatus]) | Out-Null
            }
        }
    }
    Catch {
        Write-Warning "Could not toggle Wi-Fi radio via Radio API: $_"
    }
}

function Enable-Wifi {
    $adapter = Get-WifiAdapter
    if (-not $adapter) {
        Write-Warning "No Wi-Fi adapter found."
        return
    }

    if ($adapter.Status -eq 'Disabled') {
        Write-Output "Enabling Wi-Fi adapter: $($adapter.Name)"
        Enable-NetAdapter -Name $adapter.Name -Confirm:$false
    }

    Enable-WifiRadio

    # Make sure WLAN AutoConfig service is running, otherwise netsh wlan fails.
    $svc = Get-Service -Name WlanSvc -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -ne 'Running') {
        Set-Service -Name WlanSvc -StartupType Automatic
        Start-Service -Name WlanSvc
    }
}

function Connect-Wifi {
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SSID,
        [Parameter(Mandatory=$true, Position=1)]
        [string]$Password
    )

    Enable-Wifi

    # Create the Wi-Fi profile XML content
    $ProfileXml = @"
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
    <name>$SSID</name>
    <SSIDConfig>
        <SSID>
            <name>$($SSID)</name>
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
                <keyMaterial>$($Password)</keyMaterial>
            </sharedKey>
        </security>
    </MSM>
</WLANProfile>
"@

    # Save the profile XML to a temporary file
    $TempProfilePath = [System.IO.Path]::GetTempFileName() + ".xml"
    Try {
        Set-Content -Path $TempProfilePath -Value $ProfileXml

        # Remove profile with the same name, just in case
        netsh wlan delete profile "$SSID" 2>&1 | Out-Null

        # Add the Wi-Fi profile to the system
        netsh wlan add profile filename="$TempProfilePath" 2>&1 | Out-Null

        # Connect to the Wi-Fi network
        netsh wlan connect name="$SSID" 2>&1 | Out-Null
    }
    Finally {
        Remove-Item -Path $TempProfilePath -ErrorAction Ignore
    }

    # Test
    $TryIdx = 1
    Do {
        Try {
            $Success = Test-Connection "www.google.com" -Quiet
        }
        Catch {
            Write-Output "Test request failed. Try #$TryIdx"
        }
        $TryIdx++
    } Until ($Success)

    Write-Output "Connected to Wi-Fi network $SSID."
}