Param(
  [parameter(mandatory=$true)][string]$Distro,
  [parameter(mandatory=$true)][string]$InstallLocation
)

$ErrorActionPreference = "Stop"

#$uri = "http://cdimage.ubuntu.com/ubuntu-base/releases/24.04/release/ubuntu-base-24.04.4-base-amd64.tar.gz"
$uri = "http://ftp.jaist.ac.jp/pub/Linux/ubuntu-cdimage/ubuntu-base/releases/24.04/release/ubuntu-base-24.04.4-base-amd64.tar.gz"
$sha256sum = "C1E67EF7B17A6300E136118BD1DC04725009CB376C1AAD10ABCF8CD453628D58"
$tarball = Join-Path $PSScriptRoot ([System.IO.Path]::GetFileName($uri))

If (![System.IO.File]::Exists($tarball)) {
  Invoke-WebRequest -Uri $uri -OutFile $tarball
}

$hash = (Get-FileHash $tarball -Algorithm SHA256).Hash
If ($hash -ne $sha256sum) {
  Write-Error "Checksum failed. Please delete $tarball manually."
}

wsl.exe --import $Distro $InstallLocation $tarball --version 2
wsl.exe -d $Distro apt update
wsl.exe -d $Distro env DEBIAN_FRONTEND=noninteractive apt install -y ubuntu-wsl
wsl.exe -d $Distro /bin/bash -c "( echo [boot]; echo systemd=true ) >> /etc/wsl.conf"
wsl.exe -t $Distro

$scriptsdir = Join-Path $PSScriptRoot "scripts"
Get-ChildItem $scriptsdir -Filter *.sh | Sort-Object -Property FullName | Foreach-Object {
  (Get-Content $_.FullName) -join "`n" | wsl.exe -d $Distro /bin/bash -l
}

wsl.exe -t $Distro

Remove-Item $tarball
#
