Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Confirm that Skrog, rather than another runner-installed Docker context, is active.
Write-Output "Checking Docker context..."
$dockerContext = docker context show
if ($dockerContext -ne "skrog") {
  throw "Expected Docker context 'skrog'."
}
Write-Output "Docker context: $dockerContext"

# Verify the expected Linux daemon, bundled CLI plugins, registry access, and bind mounting.
Write-Output "Checking Docker engine..."
$dockerOsType = docker info --format '{{.OSType}}'
if ($dockerOsType -ne "linux") {
  throw "Expected a Linux Docker engine."
}
Write-Output "Docker engine OS: $dockerOsType"

Write-Output "Checking Docker Buildx..."
docker buildx version

Write-Output "Checking container registry access..."
docker buildx imagetools inspect --raw ghcr.io/aicage-dev/aicage:codex-ubuntu | Out-Null

Write-Output "Checking read-only bind mounts..."
docker run --rm --mount "type=bind,src=$env:RUNNER_TEMP,dst=/host,readonly" alpine:3.22 test -d /host

Write-Output "Docker verification passed."
