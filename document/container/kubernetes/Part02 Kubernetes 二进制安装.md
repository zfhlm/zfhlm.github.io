
# Kubernetes Kubeadm 安装

  * 官方文档：

        https://kubernetes.io/

        https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/

  * 三台服务器：

        192.168.140.141

        192.168.140.142

        192.168.140.143

## 初始化服务器

  * 更新服务器内核版本：

        (略)

  * 关闭服务器防火墙：

        systemctl stop firewalld

        systemctl disable firewalld

  * 更改服务器 hostname 配置：

        hostnamectl set-hostname k8s-141

        hostnamectl set-hostname k8s-142

        hostnamectl set-hostname k8s-143

        echo '192.168.140.141 k8s-141' >> /etc/hosts

        echo '192.168.140.142 k8s-142' >> /etc/hosts

        echo '192.168.140.143 k8s-143' >> /etc/hosts

  * 禁用 selinux 访问控制：

        sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

  * 禁用 swap 内存交换：

        sed -i 's/.*swap.*/#&/' /etc/fstab

  * 配置服务器时间同步：

        yum install ntpdate -y

        ntpdate time.windows.com

  * 配置服务器 ipvs

        vi /etc/sysctl.conf

        =>

            net.ipv4.ip_forward=1

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

  * 配置服务器 ipv4 流量网桥：

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

  * 完成后重启服务器：

        reboot

## 初始化 docker 容器引擎

  * 安装 docker 容器：

        cd /usr/local/software

        curl -fsSL https://get.docker.com -o get-docker.sh

        chmod 777 ./get-docker.sh && sh ./get-docker.sh

        systemctl enable docker

        systemctl enable containerd

        systemctl start docker

        systemctl start containerd

  * 更改 docker cgroup 驱动类型：

        mkdir -p /etc/docker

        vi /etc/docker/daemon.json

        =>

            {
                "exec-opts": ["native.cgroupdriver=systemd"]
            }

        systemctl restart docker

        systemctl restart containerd

## 部署 Etcd 集群

  * 生成 CA 证书：

        cd /usr/local/software

        yum install -y wget vim net-tools

        wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64

        wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64

        wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64

        chmod +x cfssl*

        mv cfssl_linux-amd64 cfssl

        mv cfssljson_linux-amd64 cfssljson

        mv cfssl-certinfo_linux-amd64 cfssl-certinfo

        mv cfssl* /usr/bin/
