#!/bin/bash

# get newest packages
sudo apt-get update
sudo apt-get install -y perl
sudo perl -p -i -e "s/^deb cdrom/#deb cdrom/g" /etc/apt/sources.list

# install opensshd
sudo apt-get install -y openssh-server

# install docker-ce
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo apt-add-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update && sudo apt-get install -y docker-ce

# install kubernetes
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update && sudo apt-get install -y kubelet kubeadm kubectl

# add user to docker group
#sudo usermod -a -G docker $USER
sudo gpasswd -a $USER docker
#newgrp -
#exec sudo su -l $USER

# install docker-machine
curl -kL https://github.com/docker/machine/releases/download/v0.14.0/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine && sudo install /tmp/docker-machine /usr/local/bin/docker-machine

# install virtualbox
sudo apt-get install -y virtualbox

# install rancher
mkdir -p ~/.docker/machine/cache/
wget --no-check-certificate https://github.com/boot2docker/boot2docker/releases/download/v17.12.1-ce/boot2docker.iso && mv boot2docker.iso ~/.docker/machine/cache/
wget --no-check-certificate https://releases.rancher.com/os/latest/rancheros.iso && mv rancheros.iso ~/.docker/machine/cache/

# run rancher with docker group
#exec sg docker "docker run -d --restart=unless-stopped -p 8080:8080 rancher/server:stable"
newgrp - docker










