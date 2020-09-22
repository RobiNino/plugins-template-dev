#!/bin/bash
set -e

#function build(goos, goarch, exeName)
build () {
  export GOOS="$1"
  export GOARCH="$2"
  exeName="$3"

  CGO_ENABLED=0 go build -o "$exeName" -ldflags '-w -extldflags "-static"' main.go
}

#function buildAndUpload(pkg, goos, goarch, fileExtension)
buildAndUpload () {
  pkg="$1"
  goos="$2"
  goarch="$3"
  fileExtension="$4"
  exeName="$JFROG_CLI_PLUGIN_PLUGIN_NAME$fileExtension"

  build $goos $goarch $exeName

  destPath="robi-t/jfrog-cli-plugins/$JFROG_CLI_PLUGIN_PLUGIN_NAME/$JFROG_CLI_PLUGIN_VERSION/$pkg/$exeName"
  ./jfrog rt u "./$exeName" "$destPath" --url=https://ecosysjfrog.jfrog.io/artifactory --user=$int_robi_eco_user --apikey=$int_robi_eco_apikey
}

# Download JFrog CLI
curl -fL https://getcli.jfrog.io | sh

# Build and upload for every architecture
buildAndUpload 'windows-amd64' 'windows' 'amd64' '.exe'
buildAndUpload 'linux-386' 'linux' '386' ''
buildAndUpload 'linux-amd64' 'linux' 'amd64' ''
buildAndUpload 'linux-arm64' 'linux' 'arm64' ''
buildAndUpload 'linux-arm' 'linux' 'arm' ''
buildAndUpload 'mac-386' 'darwin' 'amd64' ''
