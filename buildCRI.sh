sudo apt-get -y install golang-1.10-go

mkdir ~/go
GOPATH=~/go
PATH=$PATH:/usr/lib/go-1.10/bin

go get github.com/kubernetes-incubator/cri-tools/cmd/crictl




