Param(
  [parameter(mandatory=$true)][string]$Distro,
  [parameter(mandatory=$true)][string]$InstallLocation
)

$ErrorActionPreference = "Stop"

#$uri = "http://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04.3-base-amd64.tar.gz"
$uri = "http://ftp.jaist.ac.jp/pub/Linux/ubuntu-cdimage/ubuntu-base/releases/22.04/release/ubuntu-base-22.04.3-base-amd64.tar.gz"
$sha256sum = "AD33B7AE47B75C92C2E2FE21FD4612E15357E67679D8751D6CE892A475BE24FE"
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
  # Copy the script into the distro and run it from a file rather than piping it
  # to bash's stdin: any command in the script that reads stdin (npm, apt, ...)
  # otherwise swallows the rest of the script, so the remaining steps are
  # skipped silently.
  (Get-Content $_.FullName) -join "`n" | wsl.exe -d $Distro /bin/bash -c "cat > /root/provision.sh"
  If ($LASTEXITCODE -ne 0) { Write-Error "Failed to copy $($_.Name) into $Distro." }
  wsl.exe -d $Distro /bin/bash -l /root/provision.sh
  If ($LASTEXITCODE -ne 0) { Write-Error "$($_.Name) failed with exit code $LASTEXITCODE." }
  wsl.exe -d $Distro rm -f /root/provision.sh
}

wsl.exe -t $Distro

Remove-Item $tarball
#
