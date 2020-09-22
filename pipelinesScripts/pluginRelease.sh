#function build(goos, goarch, exeName)
build () {
  echo build
  export GOOS="$0"
  export GOARCH="$1"
  CGO_ENABLED=0 go build -o "$2" -ldflags '-w -extldflags "-static"' main.go
}
#function buildAndUpload(goos, goarch, fileExtension)
buildAndUpload () {
  echo buildAndUpload
  goos="$0"
  goarch="$1"
  fileExtension="$2"

  exeName = "$JFROG_CLI_PLUGIN_REPO_NAME$fileExtension"
  build $0 $1 $exeName
}
curl -fL https://getcli.jfrog.io | sh
echo "HERE"

# Build and upload for every architecture
buildAndUpload 'windows', 'amd64', '.exe'
buildAndUpload 'linux', '386', ''
#declare -a windows-amd64=("element1" "element2" "element3")