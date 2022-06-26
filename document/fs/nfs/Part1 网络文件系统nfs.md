
# 配置 nfs 网络文件系统

# 服务器准备

    192.168.140.134     节点一，nfs客户端

    192.168.140.135     节点二，nfs服务端，提供挂载文件服务

#### 节点二 配置 nfs 服务

    使用 yum 安装，输入命令：

        yum -y install nfs-utils rpcbind

        vi /etc/exports

        =>

          /usr/local/software 192.168.140.0/24(rw,sync,no_subtree_check,no_root_squash)

        systemctl enable rpcbind

        systemctl enable nfs-server

        systemctl start rpcbind

        systemctl start nfs

        rpcinfo -p | grep nfs

        showmount -e 192.168.140.135

        ->

            Export list for 192.168.140.135:
            /usr/local/software 192.168.140.0/24

    上传测试安装包到 nfs 目录：

        /usr/local/software

        echo test > test.txt

        ll

        ->

            -rw-r--r--. 1 root root        5 Jun 26 13:48 test.txt

#### 节点一 挂载 nfs 服务

    使用yum 安装，输入命令：

        yum install -y nfs-utils

        systemctl enable rpcbind

        systemctl start rpcbind

        # 查看 nfs 服务
        showmount -e 192.168.140.135

        ->

            Export list for 192.168.140.135:
            /usr/local/software 192.168.140.0/24

    挂载 nfs 服务到本地目录，输入命令：

        mkdir /usr/local/software/

        mount -t nfs 192.168.140.135:/usr/local/software/ /usr/local/software/

        cd /usr/local/software/

        ll

        ->

            -rw-r--r--. 1 root root        5 Jun 26 13:48 test.txt

    重启之后，挂载配置会丢失，将挂载命令添加到开机自启动，输入命令：

        vi /etc/systemd/system/nfs-software.service

        =>

            [Unit]
            Description= nfs for /usr/local/software
            Wants=network-online.target rpcbind.target

            [Service]
            Type=simple
            ExecStart=/usr/bin/mount -t nfs 192.168.140.135:/usr/local/software/ /usr/local/software/
            Restart=always
            RestartSec=10s

            [Install]
            WantedBy=multi-user.target

        systemctl daemon-reload

        systemctl enable nfs-software

        reboot

        cd /usr/local/software

        ll

        ->

            -rw-r--r--. 1 root root        5 Jun 26 13:48 test.txt
