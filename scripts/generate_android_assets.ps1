Add-Type -AssemblyName System.Drawing

function Resize-Image {
    param (
        [string]$sourcePath,
        [string]$targetPath,
        [int]$width,
        [int]$height
    )
    $folder = Split-Path -Parent $targetPath
    if (!(Test-Path -Path $folder)) {
        New-Item -ItemType Directory -Force -Path $folder | Out-Null
    }
    $src = [System.Drawing.Image]::FromFile($sourcePath)
    $dest = New-Object System.Drawing.Bitmap($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($dest)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($src, 0, 0, $width, $height)
    $src.Dispose()
    $g.Dispose()
    $dest.Save($targetPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $dest.Dispose()
    Write-Host "Generated: $targetPath ($width x $height)"
}

$logoMaster = "assets/images/logo.png"
$resDir = "android/app/src/main/res"

# Mipmaps (App Icons)
Resize-Image $logoMaster "$resDir/mipmap-mdpi/ic_launcher.png" 48 48
Resize-Image $logoMaster "$resDir/mipmap-hdpi/ic_launcher.png" 72 72
Resize-Image $logoMaster "$resDir/mipmap-xhdpi/ic_launcher.png" 96 96
Resize-Image $logoMaster "$resDir/mipmap-xxhdpi/ic_launcher.png" 144 144
Resize-Image $logoMaster "$resDir/mipmap-xxxhdpi/ic_launcher.png" 192 192

# Splash Logo
Resize-Image $logoMaster "$resDir/drawable/splash_logo.png" 200 200
