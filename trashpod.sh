sudo systemctl stop rke2-agent
sudo systemctl disable rke2-agent


sudo rm -f /usr/local/bin/rke2*
sudo rm -f /usr/bin/rke2*

sudo rm -rf /etc/rancher
sudo rm -rf /var/lib/rancher
sudo rm -rf /var/lib/rke2
sudo rm -rf /etc/systemd/system/rke2-agent.service
sudo rm -rf /etc/systemd/system/rke2-agent.service.env

sudo rm -rf /etc/cni
sudo rm -rf /opt/cni
sudo rm -rf /var/lib/cni
sudo rm -rf /var/lib/kubelet
sudo rm -rf /etc/kubernetes

sudo systemctl daemon-reload