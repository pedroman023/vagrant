#!/usr/bin/env bash

## Worker nodes steps to join the cluster ##
kubeadm join ...

## add kube config file ##
## get admin config file from cp node into worker's .kube/config ##
mkdir -p $HOME/.kube;
sudo scp vagrant@kubemaster:/etc/kubernetes/admin.conf $HOME/.kube/config;
sudo chown $(id -u):$(id -g) $HOME/.kube/config

## change worker ip to cluster ##
## add the --node-ip=<ip> to the kubelet config ##
eth1_ip=$(ifconfig eth1 | grep "inet " | awk '{print $2}')
arg="--node-ip=$eth1_ip"
sed -i "s/\"/\"$arg /" /var/lib/kubelet/kubeadm-flags.env

systemctl daemon-reload
systemctl restart kubelet