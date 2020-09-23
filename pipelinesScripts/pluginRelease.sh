#!/bin/bash
set -eu

#function build(goos, goarch, exeName)
build () {
  export GOOS="$1"
  export GOARCH="$2"
  exeName="$3"
  echo "Building $exeName for $GOOS $GOARCH ..."

  CGO_ENABLED=0 go build -o "$exeName" -ldflags '-w -extldflags "-static"' main.go
}

#function verifyUniqueVersion(versionPath)
verifyUniqueVersion () {
  echo "Verifying version uniqueness..."
  versionPath="$1"
  res=$(curl -o /dev/null -s -w "%{http_code}\n" "$JFROG_CLI_PLUGINS_REGISTRY_URL/$versionPath")
  echo "Artifactory response: $res"

  exitCode=$?
  if [ $exitCode -ne 0 ]; then
    echo "Error: Failed verifying uniqueness of the plugin's version"
    exit $exitCode
  fi

  if [ $res -eq 200 ]; then
    echo "Error: Version already exists in registry"
    exit 1
  fi
}

#function buildAndUpload(pkg, goos, goarch, fileExtension)
buildAndUpload () {
  pkg="$1"
  goos="$2"
  goarch="$3"
  fileExtension="$4"
  exeName="$JFROG_CLI_PLUGIN_PLUGIN_NAME$fileExtension"

  versionFolderPath="robi-t/jfrog-cli-plugins/$JFROG_CLI_PLUGIN_PLUGIN_NAME/$JFROG_CLI_PLUGIN_VERSION/"
  verifyUniqueVersion $versionFolderPath

  build $goos $goarch $exeName

  destPath="$versionFolderPath$pkg/$exeName"
  echo "Uploading to $JFROG_CLI_PLUGINS_REGISTRY_URL/$destPath ..."

  ./jfrog rt u "./$exeName" "$destPath" --url="$JFROG_CLI_PLUGINS_REGISTRY_URL" --user=$int_robi_eco_user --apikey=$int_robi_eco_apikey
  exitCode=$?
  if [ $exitCode -ne 0 ]; then
    echo "failed uploading plugin"
    exit exitCode
  fi
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
