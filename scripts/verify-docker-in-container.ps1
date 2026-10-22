Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Skrog exposes Docker through a Windows named pipe. Docker translates this bind mount into
# the Unix socket expected by processes running inside the test container.
Write-Output "Checking Docker access from a container..."
$dockerHost = docker context inspect skrog --format '{{.Endpoints.docker.Host}}'
if ($dockerHost -notmatch '^npipe:////') {
  throw "Expected a named-pipe Docker endpoint by Skrog, got: $dockerHost"
}

$pipePath = $dockerHost -replace '^npipe:////', '//'
$dockerServerOs = docker run --rm `
  --mount "type=bind,src=$pipePath,dst=/var/run/docker.sock" `
  --env DOCKER_HOST=unix:///var/run/docker.sock `
  docker:29-cli version --format '{{.Server.Os}}'
if ($LASTEXITCODE -ne 0) {
  throw "Container could not access the Docker engine."
}

Write-Output "Docker server OS from container: $dockerServerOs"
