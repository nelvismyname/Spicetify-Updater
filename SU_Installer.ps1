$sh = New-Object -ComObject WScript.Shell
$sc = $sh.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\SU_Updater.lnk")
$sc.TargetPath = "$PSScriptRoot\SU_Updater.bat"
$sc.WorkingDirectory = $PSScriptRoot
$sc.Save()