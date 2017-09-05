#!/bin/bash
sudo yum makecache fast
sudo yum install -y docker git wget vim
sudo systemctl enable docker && sudo systemctl start docker
sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
sudo chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
sudo setenforce 0
sudo yum install -y kubelet kubeadm
sudo systemctl enable kubelet && sudo systemctl start kubelet
echo "net.bridge.bridge-nf-call-iptables = 1" | sudo tee --append /etc/sysctl.conf
sudo sysctl -p
curl -LO https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz && \
tar -xzf go1.8.3.linux-amd64.tar.gz && \
sudo mv go /usr/local
echo "export GOROOT=/usr/local/go" >> ~/.bash_profile
echo "export GOPATH=\$HOME/Projects/Proj1" >> ~/.bash_profile
echo "export PATH=\$GOPATH/bin:\$GOROOT/bin:\$PATH" >> ~/.bash_profile
source ~/.bash_profile
git clone https://github.com/Intel-Corp/multus-cni.git
cd multus-cni
./build
sudo cp bin/multus /opt/cni/bin/
