#!/usr/bin/env bash

echo "Copying calico config file to root dir..."
mkdir /root/kubeadm
sudo cp files/calico.yaml /root/kubeadm

## start kubeadm with eth1 interface (eth0 is vagrant interface) (must be root)##
eth1_ip=$(ifconfig eth1 | grep "inet " | awk '{print $2}')
kubeadm init --apiserver-advertise-address=$eth1_ip --apiserver-cert-extra-sans=$eth1_ip --node-name k8scp --pod-network-cidr=172.16.0.0/12

## Allow non-root user admin access to cluster (as regular user) ##
## This allows the access of a regular user to the cluster api (kube-api) ##
## If you are getting a connection refused to localhost:8080 it means you dont have the .kube/config file created ##
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

## Apply network plugin configuration into cluster ##
sudo cp /root/calico.yaml ~
kubectl apply -f calico.yaml
# kubectl delete -f calico.yaml

## Apply kubectl completion bash (as regular user) ##
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> $HOME/.bashrc

## enable the cp to run non-infrastructure pods ##
kubectl describe node | grep -i taint # to view the taints
kubectl taint nodes --all node-role.kubernetes.io/master-