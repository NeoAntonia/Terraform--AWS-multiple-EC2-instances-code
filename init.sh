#!/bin/bash
# Created by Abraão Silva
# Install docker in centos

# Remove any old versions
sudo yum remove docker docker-common docker-selinux docker-engine

# Install required packages
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

# Configure docker repository
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker-ce
sudo yum install docker-ce -y

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Post Installation Steps
# Create Docker group
sudo groupadd docker

# Add user to the docker group
sudo usermod -aG docker $USER

echo "Installation Complete -- Logout and Log back"

# Install docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Permssion +x execute binary
chmod +x /usr/local/bin/docker-compose

# Create link symbolic 
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Check Version docer-compose
echo "Installation Complete -- Logout and Log back"
docker-compose --version

# KUBERNETES
# Ensure system is fully patched
sudo yum -y makecache fast
sudo yum -y update

# Disable swap
sudo swapoff -a

#disable selinux 
sudo setenforce 0
sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
# comment out swap mount in /etc/fstab
sudo vi /etc/fstab

# Disable default iptables configuration as it will break kubernetes services (API, coredns, etc...)
sudo sh -c "cp /etc/sysconfig/iptables /etc/sysconfig/iptables.ORIG && iptables --flush && iptables --flush && iptables-save > /etc/sysconfig/iptables"
sudo systemctl restart iptables.service

# Load/Enable br_netfilter kernel module and make persistent
sudo modprobe br_netfilter
sudo sh -c "echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables"
sudo sh -c "echo '1' > /proc/sys/net/bridge/bridge-nf-call-ip6tables"
sudo sh -c "echo 'net.bridge.bridge-nf-call-iptables=1' >> /etc/sysctl.conf"
sudo sh -c "echo 'net.bridge.bridge-nf-call-ip6tables=1' >> /etc/sysctl.conf"

# Install dependencies for docker-ce
sudo yum -y install yum-utils device-mapper-persistent-data lvm2

# Add the docker-ce repository
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo sh -c 'cat <<EOF>> /etc/hosts 
aws_instance.app_server.*.private_ip 
EOF'
# Add the Kubernetes Repository
sudo sh -c 'cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF'

# Update yum cache after adding repository
sudo yum -y makecache fast

# Install latest supported docker runtime (18.06 is the latest runtime supported by Kubernetes v1.13.2)
#sudo yum -y install docker-ce-18.06.1.ce

# Install Kubernetes
sudo yum -y install kubelet kubeadm kubectl

# Enable kubectl bash-completion
sudo yum -y install bash-completion
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc

# Enable docker and kubelet services
#sudo systemctl enable docker.service
#sudo systemctl enable kubelet.service

# reboot
sudo reboot

# Check what cgroup driver that docker is using
sudo docker info | grep -i cgroup

# Add the cgroup driver from the previous step to the kublet config as an extra argument
sudo sed -i "s/^\(KUBELET_EXTRA_ARGS=\)\(.*\)$/\1\"--cgroup-driver=$(sudo docker info | grep -i cgroup | cut -d" " -f3)\2\"/" /etc/sysconfig/kubelet


