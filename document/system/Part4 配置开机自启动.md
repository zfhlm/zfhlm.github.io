
#### 配置开机自启动

    centos7 以上版本使用 systemd 对开启启动进行管理，systemd 存在目录：

        /lib/systemd/system/    系统存放目录

        /etc/systemd/system/    用户存放目录

    2，创建自启动脚本，以下配置基于 nginx 进行示例：

        cd /etc/systemd/system

        vi nginx.service

        =>

            [Unit]
            Description=The NGINX HTTP and reverse proxy server
            After=syslog.target network-online.target remote-fs.target nss-lookup.target
            Wants=network-online.target

            [Service]
            # 目标命令以 daemon 方式运行，使用 Type=forking，例如 nginx、zookeeper等
            # 目标命令以前台进程方式运行，使用 Type=simple
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

        systemctl start nginx

        systemctl reload nginx

        systemctl stop nginx

    3，配置开启自启动，输入命令：

        systemctl enable nginx.service

        reboot
