#function build(goos, goarch, exeName)
build () {
  export GOOS="$0"
  export GOARCH="$1"
  CGO_ENABLED=0 go build -o "$2" -ldflags '-w -extldflags "-static"' main.go
  popd plugins-template-dev
}
#function buildAndUpload(goos, goarch, pluginExeName, fileExtension)
buildAndUpload () {
    if [ $# -eq 4 ]
      then
      fileExtension="$4"
      else
      fileExtension=""
    fi

    exeName = "pluginExeName$fileExtension"
    build $0 $1 $exeName
}
curl -fL https://getcli.jfrog.io | sh
echo "HERE"
declare -a windows-amd64=("element1" "element2" "element3")