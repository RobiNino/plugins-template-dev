#!/bin/bash
set -eu

#function build(goos, goarch, exeName)
build () {
  export GOOS="$1"
  export GOARCH="$2"
  exeName="$3"
  echo "building $exeName for $GOOS $GOARCH ..."

  CGO_ENABLED=0 go build -o "$exeName" -ldflags '-w -extldflags "-static"' main.go
}

#function verifyUniqueVersion(versionPath)
verifyUniqueVersion () {
  echo "verifying version uniqueness..."
  versionPath="$1"
  res=$(curl -o /dev/null -s -w "%{http_code}\n" "https://ecosysjfrog.jfrog.io/artifactory/$versionPath")
  echo "res $res"

  exitCode=$?
  if [ $exitCode -ne 0 ]; then
    echo "failed verifying uniqueness of the plugin's version"
    exit exitCode
  fi

  if [ $res -eq 200 ]; then
    echo "version already exists in registry"
    exit exitCode
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
  echo "uploading to $destPath ..."

  ./jfrog rt u "./$exeName" "$destPath" --url=https://ecosysjfrog.jfrog.io/artifactory --user=$int_robi_eco_user --apikey=$int_robi_eco_apikey
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
