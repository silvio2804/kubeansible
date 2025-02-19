# Kubernetes Cluster Deployment with Ansible

This project automates the setup and configuration of a Kubernetes cluster using Ansible. It deploys a multi-node Kubernetes cluster, configures MetalLB for Load Balancing, sets up a persistent storage solution using NFS, and deploys an Apache server with horizontal scaling.

# Goal
Demonstrate k8s Load balancing and autoscaling. Cluster deploys an HTTP server that will replicated automatically when the cluster is stressed.

## Cluster Nodes
The Kubernetes cluster consists of the following nodes:

| Role            | IP Address       | Description                 |
|----------------|----------------|-----------------------------|
| **Master Node** | 192.168.1.6    | Controls the cluster        |
| **Worker Node** | 192.168.1.7    | Runs application workloads  |
| **Worker Node** | 192.168.1.8    | Runs application workloads  |
| **Ansible Node** | 192.168.1.5     | Manages automation          |
| **NFS Node** | 192.168.1.9    | Manages shared storage          |

In this project, each Node is a **Virtualbox Virtual Machine**, to ensure completed isolation.
The Os used is by the nodes is **Alma Linux 9.4**

## Features
- Automated Kubernetes cluster setup (Master and Worker nodes)
- MetalLB configuration for LoadBalancer services
- Persistent storage provisioning using NFS
- Apache deployment with Horizontal Pod Autoscaler (HPA)
- Centralized deployment using Ansible playbooks

## Prerequisites
Before running this Ansible playbook, ensure you have:
- **Ansible installed** on the Ansible Node
- **SSH access** to all Kubernetes nodes with root privileges, coping Ansible ssh-key into all clusters' nodes.

**You don't need to install kubernetes, Ansible automates the whole process.**

## Installation Steps

### 1. Clone the Repository
```sh
git clone https://github.com/your-repo/ansible-kubernetes.git
cd ansible-kubernetes
```

### 2. Verify connectivity

`ansible -i hosts all -m ping`

### 3. Create a Kube user with Ansible
`ansible-playbook -i hosts create-users.yml`

### 4. Install kubernetes on all nodes (expept Ansible and NFS)

`ansible-playbook -i hosts install-kube.yml`

### 5. Setup the master node

`ansible-playbook -i hosts master-setup.yml`

### 6. Join worker nodes to the cluster

`ansible-playbook -i hosts worker-setup.yml`

### 7. Complete  configuration by deploying:

* Nfs: persistent volume and persistent volume claim;
* Apache-deployment, that is the http application, configured as a Load balancer service 
* Metric-server, that measures cluster metrics, as CPU, memory used etc..
* Horizontal Pod Autoscaler (HPA), that replicate the pods, based on the load
* Metallb load balancer, that asign External Ip to pods, and provides load balancing

`ansible-playbook -i hosts main.yml`

### 8. Verify cluster works
In the master node:
* kubectl get pod -n kube-system
* kubectl get node
* kubectl get pod -o wide
* kubectl get svc
* kubectl get hpa
* kubectl get pv
* kubectl get pvc

### 9. stress test
Stress test is performed using **ab** apache benchmark:
`ab -n 1000 -c 10 http://<EXTERNAL_IP_BY_METALLB>:<PORT>/py.php?n=10000000`

See the scale up using:
`kubectl get pod` to see how many pods are created (max is set to 5)
`kubectl get hpa` to see cpu metrics.











