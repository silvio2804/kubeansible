#!/bin/bash

# Definisci i nodi da resettare
NODES=("master" "worker1" "worker2")

# Comandi da eseguire su ogni nodo
RESET_COMMANDS="
echo '>> Stopping kubelet and resetting kubeadm'
sudo systemctl stop kubelet
sudo kubeadm reset -f

echo '>> Removing Kubernetes configuration files'
sudo rm -rf /etc/kubernetes /var/lib/kubelet

echo '>> Removing CNI network configurations'
sudo rm -rf /etc/cni /opt/cni /var/lib/cni /var/run/calico

echo '>> Removing container runtime data (containerd)'
sudo systemctl stop containerd
sudo rm -rf /var/lib/containerd
sudo systemctl restart containerd

echo '>> Flushing iptables and network settings'
sudo iptables --flush
sudo iptables -tnat --flush
sudo ip link set cni0 down 2>/dev/null
sudo ip link set flannel.1 down 2>/dev/null
sudo ip link delete cni0 2>/dev/null
sudo ip link delete flannel.1 2>/dev/null

echo '>> Disabling and removing kubelet service'
sudo systemctl disable kubelet
sudo rm -f /etc/systemd/system/kubelet.service
sudo systemctl daemon-reload

echo '>> Uninstalling Kubernetes packages (kubeadm, kubelet, kubectl)'
sudo dnf remove -y kubeadm kubelet kubectl

echo '>> Uninstalling kubeconfig '
sudo rm  -rf $HOME/.kube

echo '>> Uninstallink kube_join_command for workers'
sudo rm  /etc/kube_join_command
echo '>> Rebooting node'
sudo reboot
"

# Esegui il reset su ciascun nodo via SSH
for NODE in "${NODES[@]}"; do
    echo ">>> Verificando la connessione a $NODE"
    
    # Verifica se il nodo è raggiungibile tramite SSH
    if ssh -o ConnectTimeout=5 "$NODE" exit; then
        echo ">>> Resettando Kubernetes su $NODE"
        ssh "$NODE" "$RESET_COMMANDS"
    else
        echo ">>> Errore: impossibile connettersi a $NODE"
    fi
done

echo ">>> Reset completato su tutti i nodi!"
