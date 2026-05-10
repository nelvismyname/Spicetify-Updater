Add-Type -AssemblyName System.Windows.Forms,System.Drawing
$n = New-Object System.Windows.Forms.NotifyIcon
$n.Icon = [System.Drawing.SystemIcons]::Information
$n.Visible = $true

if (-not (Get-Command spicetify -ErrorAction SilentlyContinue)) {
    iwr "https://raw.githubusercontent.com/spicetify/cli/main/install.ps1" -UseBasicParsing | iex
}

spicetify backup *> $null
spicetify upgrade *> $null
spicetify backup apply *> $null

$ver = (spicetify -v 2>$null).Trim()

$n.BalloonTipTitle = "Spicetify Updater"
$n.BalloonTipText  = "Updated, Version: $ver"
$n.ShowBalloonTip(1)
$n.Dispose()