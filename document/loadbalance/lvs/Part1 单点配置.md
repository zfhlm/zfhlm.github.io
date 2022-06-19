
#### 安装准备

    1，下载安装包

        下载地址：http://www.linuxvirtualserver.org/

        找到 ipvsadm-1.26 release地址，下载安装包：ipvsadm-1.26.tar.gz

        上传到服务器目录：/usr/local/software

        注意：编译之前需要先确认linux服务器内核版本，阅读官方文档下载合适的版本

#### 编译安装

    1，初始化编译环境

        输入命令：

            yum install -y gcc-c++

            yum install -y libnl*

            yum install -y popt*

    2，编译安装ipvsadm

        输入命令：

            cd /usr/local/software

            tar -zxvf ./ipvsadm-1.26.tar.gz

            cd ./ipvsadm-1.26

            make && make install

    3，验证安装

        输入命令：

            ipvsadm

        安装成功提示信息：

            IP Virtual Server version 1.2.1 (size=4096)
            Prot LocalAddress:Port Scheduler Flags
              -> RemoteAddress:Port           Forward Weight ActiveConn InActConn

    4，常用命令参数：

        -A --add-service                    在内核的虚拟服务器表中添加一条新的虚拟服务器记录

        -E --edit-service                   编辑内核虚拟服务器表中的一条虚拟服务器记录

        -D --delete-service                 删除内核虚拟服务器表中的一条虚拟服务器记录

        -C --clear                          清除内核虚拟服务器表中的所有记录

        -R --restore                        恢复虚拟服务器规则

        -S --save                           保存虚拟服务器规则，输出为-R 选项可读的格式

        -a --add-server                     在内核虚拟服务器表的一条记录里添加一条新的真实服务器记录

        -e --edit-server                    编辑一条虚拟服务器记录中的某条真实服务器记录

        -d --delete-server                  删除一条虚拟服务器记录中的某条真实服务器记录

        -L|-l --list                        显示内核虚拟服务器表

        -t --tcp-service service-address    说明虚拟服务器提供的是tcp

        -u --udp-service service-address    说明虚拟服务器提供的是udp

        -s --scheduler scheduler            使用的调度算法，有这样几个选项rr|wrr|lc|wlc|lblc|lblcr|dh|sh|sed|nq，默认使用wlc
