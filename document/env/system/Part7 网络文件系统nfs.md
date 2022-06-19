
#### 搭建 nfs

    nfs 服务端使用 yum 安装，输入命令：

        yum -y install nfs-utils rpcbind

    nfs 服务端配置 nfs 服务，输入命令：

        vi /etc/exports

        =>

          /usr/local/software 192.168.140.0/24(rw,sync,no_subtree_check,no_root_squash)

    nfs 服务端启动 nfs 服务，输入命令：

        systemctl enable rpcbind && systemctl enable nfs-server

        systemctl start rpcbind && systemctl start nfs

        rpcinfo -p | grep nfs

    nfs 服务端上传安装包到目录：

        /usr/local/software

#### 挂载 nfs

    nfs 客户端使用yum 安装，输入命令：

        yum install -y nfs-utils

    nfs 客户端启动 nfs 服务，输入命令：

        systemctl enable rpcbind

        systemctl start rpcbind

    nfs 客户端查看 nfs 服务端挂载信息，输入命令：

        showmount -e 192.168.140.210

    nfs 客户端挂载 nfs 目录，输入命令：

        mkdir /usr/local/software/

        mount -t nfs 192.168.140.210:/usr/local/software/ /usr/local/software/

        ll /usr/local/software

        -> 输出远程目录文件列表
