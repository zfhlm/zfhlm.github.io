
# kubernetes

### 服务器配置

	三台服务器：

		192.168.140.203(控制节点，最低配置 2核CPU 2G内存)

		192.168.140.204(运行节点)

		192.168.140.205(运行节点)

	更改 hostname，输入命令：

		echo '192.168.140.203 k8s-203' >> /etc/hosts

		echo '192.168.140.204 k8s-204' >> /etc/hosts

		echo '192.168.140.205 k8s-205' >> /etc/hosts

	禁用 firewalld，输入命令：

		systemctl stop firewalld

		systemctl disable firewalld

	禁用 selinux，输入命令：

		sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

	禁用 swap，输入命令：

		sed -i 's/.*swap.*/#&/' /etc/fstab

	安装 docker，输入命令：

		curl -fsSL https://get.docker.com -o get-docker.sh

		chmod 777 ./get-docker.sh && sh ./get-docker.sh

		systemctl enable docker.service

		systemctl enable containerd.service

		vi /etc/docker/daemon.json

		=> {"exec-opts": ["native.cgroupdriver=systemd"]}

		systemctl daemon-reload

	重启服务器，输入命令：

		reboot

### 集群节点配置

	所有节点更改 linux ipatbles 内核参数，输入命令：

		cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
		br_netfilter
		EOF

		cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
		net.bridge.bridge-nf-call-ip6tables = 1
		net.bridge.bridge-nf-call-iptables = 1
		EOF

		sysctl --system

	所有节点使用 yum 安装，输入命令：

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

	控制节点初始化，输入命令：

		kubeadm version

		kubeadm init \
			--apiserver-advertise-address=192.168.140.203 \
			--image-repository registry.aliyuncs.com/google_containers \
			--kubernetes-version v1.22.3 \
			--service-cidr=10.1.0.0/16 \
			--pod-network-cidr=10.244.0.0/16

		export KUBECONFIG=/etc/kubernetes/admin.conf

	运行节点初始化，输入命令：

		kubeadm join 192.168.140.203:6443 --token 54rtf9.tdmelsgqc2nkhj1b \
			--discovery-token-ca-cert-hash sha256:59e3c3f335df6baec05676244102b6c67294450d71f36486574cf4a3214e6ae6

	控制节点查看所有节点，输入命令：

		kubectl get nodes

		->
			NAME      STATUS     ROLES                  AGE    VERSION
			k8s-203   NotReady   control-plane,master   9m7s   v1.22.3
			k8s-204   NotReady   <none>                 55s    v1.22.3
			k8s-205   NotReady   <none>                 27s    v1.22.3

### 集群网络配置

	控制节点配置 flannel 网络，输入命令：

			# 无法下载的情况下可以通过 GitHub 项目源码获取
		wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

		kubectl apply -f kube-flannel.yml

		kubectl get nodes

		kubectl get pod -n kube-system

### 可视工作台配置

	控制节点配置 dashboard，输入命令：

		# 无法下载的情况下可以通过 GitHub 项目源码获取
		wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.4.0/aio/deploy/recommended.yaml

		kubectl apply -f recommended.yaml

		kubectl get pods -n kubernetes-dashboard

		kubectl get svc -n kubernetes-dashboard

		kubectl patch svc kubernetes-dashboard -p '{"spec":{"type":"NodePort"}}' -n kubernetes-dashboard

		kubectl get svc -n kubernetes-dashboard

		-> 输出信息获取端口

		curl https://192.168.140.203:port

	控制节点配置 dashboard token，输入命令：

		kubectl create serviceaccount dashboard -n kubernetes-dashboard

		kubectl create rolebinding def-ns-admin --clusterrole=admin --serviceaccount=default:def-ns-admin

		kubectl create clusterrolebinding dashboard-cluster-admin --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:dashboard

		kubectl describe sa dashboard -n kubernetes-dashboard

		-> 输出信息作为下面的参数

		kubectl describe secret dashboard-token-54h7c -n kubernetes-dashboard

		-> 输出 token 作为登录 token
