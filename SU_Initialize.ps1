Add-Type -AssemblyName System.Windows.Forms, System.Drawing
$NotifyIcon = New-Object System.Windows.Forms.NotifyIcon
$NotifyIcon.Icon = [System.Drawing.SystemIcons]::Information
$NotifyIcon.Visible = $true
$StartupLnk = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Spicetify Updater.lnk"
if (-not (Test-Path $StartupLnk)) {
    $Shell = New-Object -ComObject WScript.Shell
    $Shortcut = $Shell.CreateShortcut($StartupLnk)
    $Shortcut.TargetPath = "$PSScriptRoot\Spicetify Updater.bat"
    $Shortcut.WorkingDirectory = $PSScriptRoot
    $Shortcut.Save()
}

$RepoZip = "https://github.com/nelvismyname/Spicetify-Updater/archive/refs/heads/main.zip"
$RepoVersionUrl = "https://raw.githubusercontent.com/nelvismyname/Spicetify-Updater/main/Version"
$LocalVersionFile = "$PSScriptRoot\Version"

function Get-VersionNumber($Json) {
    try {($Json | ConvertFrom-Json).version} catch {"0.0"}
}

try {
    $RemoteVersion = Get-VersionNumber (Invoke-WebRequest $RepoVersionUrl -UseBasicParsing -ErrorAction Stop).Content
    $LocalVersion  = if (Test-Path $LocalVersionFile) {Get-VersionNumber (Get-Content $LocalVersionFile -Raw)} else {"0.0"}
    if ([version]$RemoteVersion -gt [version]$LocalVersion) {
        $NotifyIcon.BalloonTipTitle = "Spicetify Updater"
        $NotifyIcon.BalloonTipText  = "Updater is Outdated. ($LocalVersion -> $RemoteVersion), Updating"
        $NotifyIcon.ShowBalloonTip(3000)
        Start-Sleep -Seconds 1
        
        $TempZip = "$env:TEMP\SU_Update.zip"
        $TempDir = "$env:TEMP\SU_Update"
        Invoke-WebRequest $RepoZip -UseBasicParsing -OutFile $TempZip -ErrorAction Stop
        if (Test-Path $TempDir) { Remove-Item $TempDir -Recurse -Force }
        Expand-Archive $TempZip -DestinationPath $TempDir -Force
        
        $ExtractedDir = Get-ChildItem $TempDir -Directory | Select-Object -First 1
        if ($ExtractedDir) {
            Get-ChildItem $ExtractedDir.FullName -File | ForEach-Object {
                Copy-Item $_.FullName -Destination "$PSScriptRoot\$($_.Name)" -Force
            }
        }
        
        Remove-Item $TempZip -Force -ErrorAction SilentlyContinue
        Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue
        $NotifyIcon.Dispose()
        
        $ScriptPath = "$PSScriptRoot\Spicetify Updater.bat"
        Start-Process cmd -ArgumentList "/c start /b `"$ScriptPath`"" -WindowStyle Hidden
        exit
    }
} catch {}

if (-not (Get-Command spicetify -ErrorAction SilentlyContinue)) {
    Invoke-WebRequest "https://raw.githubusercontent.com/spicetify/cli/main/install.ps1" -UseBasicParsing | Invoke-Expression
}

spicetify backup *> $null
spicetify upgrade *> $null
spicetify backup apply *> $null
$SpicetifyVersion = (spicetify -v 2>$null).Trim()
$NotifyIcon.BalloonTipTitle = "Spicetify Updater"
$NotifyIcon.BalloonTipText = "Updated to $SpicetifyVersion"
$NotifyIcon.ShowBalloonTip(3000)
$NotifyIcon.Dispose()