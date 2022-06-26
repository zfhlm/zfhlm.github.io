
# centos 开机自启动

### systemd

    centos7 以上版本使用 systemd 对开启启动进行管理

    systemd 配置存放目录：

        /lib/systemd/system/    系统存放目录

        /etc/systemd/system/    用户存放目录

    systemd 使用 <service-name>.service 来描述一个服务，以下为常用的配置项：

        [Unit]                      #控制单元
        Description=                #描述信息
        Before=                     #在哪些服务启动前启动
        After=                      #在哪些服务启动后启动
        Wants=                      #启动依赖哪些服务

        [Service]                   #服务描述
        Group=                      #启动使用的用户组
        User=                       #启动使用的用户名
        Type=                       #启动类型，守护进程方式启动使用forking，前台进程方式启动使用simple，前台进程方式启动需要获取就绪通知信号使用notify
        PIDFile=                    #服务进程PID文件
        ExecStartPre=               #启动前执行命令
        ExecStart=                  #启动命令
        ExecStartPost=              #启动后执行命令
        ExecReload=                 #重启命令
        ExecStop=                   #停止命令
        Restart=                    #服务挂掉重启条件
        RestartSec=                 #服务挂掉重启时间间隔

        [Install]                   #安装描述
        WantedBy=                   #指定开机自启动Target

#### nginx 开机自启动 配置示例

    添加 systemd 服务，输入命令：

        cd /etc/systemd/system

        vi nginx.service

        =>

            [Unit]
            Description=The NGINX HTTP and reverse proxy server
            After=syslog.target network-online.target remote-fs.target nss-lookup.target
            Wants=network-online.target

            [Service]
            Type=forking
            ExecStartPre=/usr/local/nginx/sbin/nginx -t
            ExecStart=/usr/local/nginx/sbin/nginx
            ExecReload=/usr/local/nginx/sbin/nginx -s reload
            ExecStop=/usr/local/nginx/sbin/nginx -s stop
            Restart=always
            RestartSec=10s

            [Install]
            WantedBy=multi-user.target

        systemctl daemon-reload

    使用 systemd 启停服务，输入命令：

        systemctl start nginx

        systemctl reload nginx

        systemctl stop nginx

    配置开启自启动，输入命令：

        # 允许服务开机启动
        systemctl enable nginx.service

        # 禁止服务开机启动
        systemctl disable nginx.service

        # 查看服务状态
        systemctl status nginx.service -l
