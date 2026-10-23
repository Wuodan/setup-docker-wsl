Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# GitHub-hosted Windows runners register Docker Engine as the `docker` service.
# Stop it so Skrog can bind the standard \\.\pipe\docker_engine named pipe.
$service = Get-Service docker -ErrorAction SilentlyContinue
if (-not $service) {
  Write-Output "Docker Engine is not installed."
  return
}

if ($service.Status -eq "Stopped") {
  Write-Output "Docker Engine is already stopped."
  return
}

Write-Output "Stopping Docker Engine..."
sc.exe stop docker | Out-Host

# sc.exe returns before the service stops, so wait for it with a bounded timeout.
$deadline = (Get-Date).AddSeconds(30)
do {
  Start-Sleep -Milliseconds 250
  $service.Refresh()
} while ($service.Status -ne "Stopped" -and (Get-Date) -lt $deadline)

if ($service.Status -ne "Stopped") {
  throw "Docker Engine did not stop within 30 seconds."
}

Write-Output "Docker Engine stopped."
