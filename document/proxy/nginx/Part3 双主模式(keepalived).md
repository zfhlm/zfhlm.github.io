
# 双主模式(nginx+keepalived)

### 配置前准备工作

    主服务器一： 192.168.140.147

    主服务器二： 192.168.140.148

    双机VIP：192.168.140.200、192.168.140.201

    两台服务器都安装好 nginx、keepalived

    启动nginx服务，将 nginx 的 index.html 都加上各自的IP地址

### 配置主服务器一 keepalived

    输入命令编辑配置文件：

        vi /etc/keepalived/keepalived.conf

        =>

            ! Configuration File for keepalived

            global_defs {
                router_id nka_master_147
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
                    auth_pass 123456
                }

                virtual_ipaddress {
                    192.168.140.200
                }

                track_script {
                   promise_nginx_or_kill_myself
                }

            }

            vrrp_instance VI_2 {

                state BACKUP
                interface ens33
                mcast_src_ip 192.168.140.147
                virtual_router_id 52
                priority 100
                advert_int 1  

                authentication {
                    auth_type PASS
                    auth_pass 456789
                }

                virtual_ipaddress {
                    192.168.140.201
                }

                track_script {
                   promise_nginx_or_kill_myself
                }

            }

### 配置主服务器二 keepalived

    输入命令编辑配置文件：

        vi /etc/keepalived/keepalived.conf

        =>

            ! Configuration File for keepalived

            global_defs {
                router_id nka_master_148
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
                    auth_pass 123456
                }

                virtual_ipaddress {
                    192.168.140.200
                }

                track_script {
                   promise_nginx_or_kill_myself
                }

            }

            vrrp_instance VI_2 {

                state MASTER
                interface ens33
                mcast_src_ip 192.168.140.148
                virtual_router_id 52
                priority 101
                advert_int 1  

                authentication {
                    auth_type PASS
                    auth_pass 456789
                }

                virtual_ipaddress {
                    192.168.140.201
                }

                track_script {
                   promise_nginx_or_kill_myself
                }

            }

### 配置双主服务器检测脚本

    (配置方式和主备模式一致)

### 启动双主服务器的keepalived

    服务器都执行命令：

        service keepalived start

    浏览器访问以下地址：

        http://192.168.140.200/

        http://192.168.140.201/

    可以看到浏览器界面显示分别显示两台服务器的欢迎页

### 测试双主keepalived功能

    关闭 主服务器一 nginx和keepalived，刷新浏览器地址：http://192.168.140.200/

    可以看到浏览器界面显示 主服务器二nginx欢迎页

    重启主服务器一 nginx和keepalived，刷新浏览器地址：http://192.168.140.200/

    可以看到显示界面已经切换回主服务器一nginx欢迎页
