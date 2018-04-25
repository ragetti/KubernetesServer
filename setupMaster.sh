#!/bin/bash
# notes
# sudo apt-get install -y git
# git clone https://github.com/ragetti/KubernetesServer.git


# add dns for PV and google
echo "nameserver 10.25.0.122" | sudo tee -a /etc/resolvconf/resolv.conf.d/base
echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolvconf/resolv.conf.d/base
sudo resolvconf -u

# add self signed certs for pv
echo | openssl s_client -connect storage.googleapis.com:443 -showcerts > bundle.txt
cat bundle.txt | awk '/BEGIN/ { i++; } /BEGIN/, /END/ { print > "pv" i ".crt" }'
sudo cp pv*.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates


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
sudo apt-get update && sudo apt-get install -y kubelet kubeadm kubectl conntrack

# add user to docker group
#sudo usermod -a -G docker $USER
sudo gpasswd -a $USER docker

# turn off swap, should be made permanent
sudo swapoff -a

# copy crictl
sudo cp crictl /usr/local/bin/

# pass bridged IPv4 traffic to iptables’ chains, requirement of CNI flannel
sudo sysctl net.bridge.bridge-nf-call-iptables=1

# initialize cluster
#sudo kubeadm init --kubernetes-version v1.10.0 --pod-network-cidr=10.244.0.0/16
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# allows local user run
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# CNI
kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
# old
#kubectl create -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml

# make group active
#newgrp - docker
echo "make sure to turn off swap in /etc/fstab"
echo "Logout and Login to have environment changes take effect"









