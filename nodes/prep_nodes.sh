#!/usr/bin/env bash

echo "Starting preparing nodes..."

## Add kubernetes repo ##
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

## Update system ##
echo "Updating system..."
sudo apt-get -y update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade

## Install tools ##
echo "Tools: Installing tools..."
sudo apt-get install -y apt-transport-https ca-certificates curl nmon htop bash-completion
echo "Tools: Finished!"

## Install docker and config ##
echo "Docker: Installing..."
sudo apt-get install -y docker.io

echo "Docker: Making sure docker uses systemd cgroup driver"
sudo mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

echo "Docker: Restarting docker services..."
sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker

echo "Docker: Finished!"

## Install Kubernetes tools ##
echo "Kubernetes: Installing..."
sudo apt-get install -y kubeadm=1.21.1-00 kubelet=1.21.1-00 kubectl=1.21.1-00
sudo apt-mark hold kubelet kubeadm kubectl
echo "Kubernetes: Finished!"

## Clean up ##
sudo apt -y autoremove

## disable swap ##
echo "Swap: disabling..."
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab # for permenant disable swap
echo "Swap: Finished!"

## add CP node to /etc/hosts ##
sudo -- sh -c "echo '192.168.1.200 k8scp' >> /etc/hosts"

echo "Finished preparing nodes!"