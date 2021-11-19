
# 主备模式(nginx+keepalived)

### 配置前准备工作

    master服务器： 192.168.140.147

    backup服务器： 192.168.140.148

    VIP：192.168.140.200

    两台服务器都安装好 nginx、keepalived

    启动nginx服务，将 nginx 的 index.html 都加上各自的IP地址

### 配置 master 服务器 keepalived

    输入命令编辑配置文件：

        cp /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak

        vi /etc/keepalived/keepalived.conf

        =>

            ! Configuration File for keepalived

            global_defs {
                router_id nka_master
            }

            vrrp_script promise_nginx_or_kill_myself {
                script "/etc/keepalived/promise_nginx_or_kill_myself.sh"
                interval 2
                weight -5
                fall 2
                rise 1
            }

            vrrp_instance VI_1 {

                state MASTER
                interface ens33
                mcast_src_ip 192.168.140.147
                virtual_router_id 51
                priority 101
                advert_int 1  

                authentication {
                    auth_type PASS
                    auth_pass nginx123456
                }

                virtual_ipaddress {
                    192.168.140.200
                }

                track_script {
                   promise_nginx_or_kill_myself
                }

            }

### 配置 backup 服务器 keepalived

    输入命令编辑配置文件：

        cp /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak

        vi /etc/keepalived/keepalived.conf

        =>

            ! Configuration File for keepalived

            global_defs {
                router_id nka_backup
            }

            vrrp_script promise_nginx_or_kill_myself {
                script "/etc/keepalived/promise_nginx_or_kill_myself.sh"
                interval 2
                weight -5
                fall 2
                rise 1
            }

            vrrp_instance VI_1 {

                state BACKUP
                interface ens33
                mcast_src_ip 192.168.140.148
                virtual_router_id 51
                priority 100
                advert_int 1  

                authentication {
                    auth_type PASS
                    auth_pass nginx123456

                }

                virtual_ipaddress {
                    192.168.140.200
                }

                track_script {
                   promise_nginx_or_kill_myself
                }

            }

### 配置主备服务器检测脚本

    脚本的作用：

        检测本机nginx的存活状况，如果nginx非存活状态，尝试启动nginx

        如果启动本机nginx不成功，将keepalived进程杀死，使VIP转移到另一台服务器

    输入命令：

        cd /etc/keepalived/

        touch promise_nginx_or_kill_myself.sh

        chmod 777 ./promise_nginx_or_kill_myself.sh

        vi ./promise_nginx_or_kill_myself.sh

    将以下内容粘贴到脚本内容：

        #!/bin/sh
        if [ $(ps -C nginx --no-header |wc -l) -eq 0 ]
        then
            /usr/local/nginx/sbin/nginx
            sleep 1
            if [ $(ps -C nginx --no-header |wc -l) -eq 0 ]
            then
                systemctl stop keepalived
            fi
        fi

### 启动主备服务器的keepalived

    主备服务器都执行命令：

        service keepalived start

    浏览器访问以下地址：

        http://192.168.140.200/

    可以看到浏览器界面显示的是 master服务器nginx欢迎页

### 测试主备keepalived功能

    关闭 master服务器 nginx 或杀死 master 服务器keepalived，刷新浏览器地址：http://192.168.140.200/

    可以看到浏览器界面显示 backup服务器nginx欢迎页

    重启master服务器nginx和keepalived，刷新浏览器地址：http://192.168.140.200/

    可以看到显示界面已经切换回master服务器nginx欢迎页
