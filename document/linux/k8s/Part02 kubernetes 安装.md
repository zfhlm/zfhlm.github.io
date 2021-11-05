
# kubernetes

	使用 kubeadm 安装 k8s 集群：命令行工具 kubectl、集群运行代理 kubelet、集群初始化工具 kubeadm

#### 服务器：

		192.168.140.203(控制节点，最低配置 2核CPU 2G内存)

		192.168.140.204(运行节点)

		192.168.140.205(运行节点)

#### 配置 hostname

	输入命令：

		echo '192.168.140.203 k8s203' >> /etc/hosts

		echo '192.168.140.204 k8s204' >> /etc/hosts

		echo '192.168.140.205 k8s205' >> /etc/hosts

		hostnamectl set-hostname k8s203

		hostnamectl set-hostname k8s204

		hostnamectl set-hostname k8s205

#### 禁用 firewalld

	输入命令：

		systemctl stop firewalld

		systemctl disable firewalld

#### 禁用 selinux

	输入命令：

		sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

#### 禁用 swap

	输入命令：

		sed -i 's/.*swap.*/#&/' /etc/fstab

#### 配置 docker

	输入命令：

		curl -fsSL https://get.docker.com -o get-docker.sh

		chmod 777 ./get-docker.sh && sh ./get-docker.sh

		systemctl enable docker.service && systemctl enable containerd.service

		vi /etc/docker/daemon.json

	更改以下内容：

		{
			"exec-opts": ["native.cgroupdriver=systemd"]
		}

#### 配置 ipvs

	输入命令：

		vi /etc/sysctl.conf

		=> net.ipv4.ip_forward=1

		sysctl -p

		yum -y install ipvsadm  ipset

		# 注意4.18以下内核 nf_conntrack 改为 nf_conntrack_ipv4
		cat > /etc/sysconfig/modules/ipvs.modules <<EOF
		modprobe -- ip_vs
		modprobe -- ip_vs_rr
		modprobe -- ip_vs_wrr
		modprobe -- ip_vs_sh
		modprobe -- nf_conntrack
		EOF

		reboot

#### 配置 k8s 网桥

	输入命令：

		lsmod | grep br_netfilter

		modprobe br_netfilter

		cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
		br_netfilter
		EOF

		cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
		net.bridge.bridge-nf-call-ip6tables = 1
		net.bridge.bridge-nf-call-iptables = 1
		EOF

		sysctl --system

#### 安装 bukeadm

	输入命令：

		cat <<EOF > /etc/yum.repos.d/kubernetes.repo
		[kubernetes]
		name=Kubernetes
		baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
		enabled=1
		gpgcheck=1
		repo_gpgcheck=1
		gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
		EOF

		yum -y install kubectl-1.22.3 kubelet-1.22.3 kubeadm-1.22.3

		systemctl enable kubelet

#### 初始化集群

	控制节点初始化，输入命令：

		kubeadm version

		kubeadm init \
			--apiserver-advertise-address=192.168.140.203 \
			--image-repository registry.aliyuncs.com/google_containers \
			--kubernetes-version v1.22.3 \
			--service-cidr=10.1.0.0/16 \
			--pod-network-cidr=10.244.0.0/16

		mkdir -p $HOME/.kube

		sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

		sudo chown $(id -u):$(id -g) $HOME/.kube/config

		ll /etc/kubernetes/

	控制节点开启 ipvs，输入命令：

		kubectl edit configmap kube-proxy -n kube-system

		=> model: "ipvs"

		kubectl delete pod $(kubectl get pod -A -n kube-system | grep kube-proxy | awk -F ' ' '{print $2}' ) -n kube-system

		ipvsadm -Ln

		-> 输出 ipvs 连接信息为正常

	运行节点初始化，输入命令：

		kubeadm join 192.168.140.203:6443 --token 54rtf9.tdmelsgqc2nkhj1b \
			--discovery-token-ca-cert-hash sha256:59e3c3f335df6baec05676244102b6c67294450d71f36486574cf4a3214e6ae6

		ll /etc/kubernetes/

#### 配置集群网络

	控制节点输入命令：

		cd /etc/kubernetes/

		wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

		kubectl apply -f kube-flannel.yml

		kubectl get nodes

		kubectl get pod -n kube-system

		->

			NAME                             READY   STATUS    RESTARTS   AGE
			coredns-7f6cbbb7b8-jtmxf         1/1     Running   0          54m
			coredns-7f6cbbb7b8-ql4z2         1/1     Running   0          54m
			etcd-k8s203                      1/1     Running   1          54m
			kube-apiserver-k8s203            1/1     Running   1          54m
			kube-controller-manager-k8s203   1/1     Running   1          54m
			kube-flannel-ds-k2mn6            1/1     Running   0          11m
			kube-flannel-ds-k66s2            1/1     Running   0          11m
			kube-flannel-ds-x6w57            1/1     Running   0          11m
			kube-proxy-5qblm                 1/1     Running   0          54m
			kube-proxy-t5fnc                 1/1     Running   0          48m
			kube-proxy-tk5qr                 1/1     Running   0          48m
			kube-scheduler-k8s203            1/1     Running   1          54m

#### 指令式命令

	发布容器，输入命令：

		kubectl create deployment nginx --image nginx --port=80 --replicas=3

		kubectl get pod -o wide -w

		curl $(kubectl get pod -o wide | grep nginx |  awk -F ' ' '{print $6}')

	模拟故障删除一个 pod，输入命令：

		kubectl delete pod nginx-7848d4b86f-d9hkj

		kubectl get pod -o wide

	创建 svc 负载均衡 nginx，输入命令：

		kubectl expose deployment nginx --port=8080 --target-port=80

		kubectl get svc

		curl $(kubectl get svc | grep nginx |  awk -F ' ' '{print $3}'):8080

	移除 nginx 服务，输入命令：

		kubectl delete svc nginx

		kubectl delete deployment nginx

#### 指令式对象配置

	创建 nginx deployment 配置文件，输入命令：

		kubectl explain deployment

		vi /usr/local/application/nginx-deployment.yaml

	添加以下内容：

		apiVersion: apps/v1
		kind: Deployment
		metadata:
			name: nginx
		spec:
			replicas: 3
			selector:
				matchLabels:
					app: nginx
			template:
				metadata:
					labels:
						app: nginx
				spec:
					containers:
						- name: nginx
							image: nginx
							ports:
								- containerPort: 80

	发布 nginx deployment 任务，输入命令：

		kubectl apply -f nginx-deployment.yaml

	移除 nginx deployment 任务，输入命令：

		kubectl delete -f nginx-deployment.yaml
