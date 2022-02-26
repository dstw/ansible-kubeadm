sudo apt -y install curl apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt -y install vim git curl wget kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

kubectl version --client
kubeadm version

# Disable swap
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a

# Enable kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Add some settings to sysctl
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload sysctl
sudo sysctl --system

# Configure persistent loading of modules
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

# Load at runtime
sudo modprobe overlay
sudo modprobe br_netfilter

# Ensure sysctl params are set
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload configs
sudo sysctl --system

# Install required packages
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

# Add Docker repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install containerd
sudo apt update
sudo apt install -y containerd.io

### Configure containerd and start service
sudo rm -f /etc/containerd/config.toml
# restart containerd
sudo systemctl restart containerd
sudo systemctl enable containerd
systemctl status containerd

sudo sed -i '/10\.80\.11\.90/d' /etc/hosts
sudo -- sh -c "echo 10.80.11.90 cluster.staging.com >> /etc/hosts"
sudo sed -i '/10\.80\.11\.90/d' /etc/cloud/templates/hosts.debian.tmpl
sudo -- sh -c "echo 10.80.11.90 cluster.staging.com >> /etc/cloud/templates/hosts.debian.tmpl"

sudo kubeadm config images pull \
  --cri-socket /run/containerd/containerd.sock

### sudo kubeadm init \
###   --pod-network-cidr=192.168.0.0/16 \
###   --cri-socket /run/containerd/containerd.sock \
###   --upload-certs \
###   --control-plane-endpoint=cluster.staging.com
###
### sudo kubeadm join cluster.staging.com:6443 --token cdrpyg.limrfntd5rpsjxjq \
###   --discovery-token-ca-cert-hash sha256:a8b181942aa27dbca9b9e4e18cd8c0058bb052cc8e27b82ab60ddbe2af615129 \
###   --control-plane --certificate-key 33a97759d5c29720687d64312ad09bf794e387bcae4e7ef1def2305d5df86a16
### 
### sudo kubeadm join cluster.staging.com:6443 --token cdrpyg.limrfntd5rpsjxjq \
###   --discovery-token-ca-cert-hash sha256:a8b181942aa27dbca9b9e4e18cd8c0058bb052cc8e27b82ab60ddbe2af615129
