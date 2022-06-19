
#### 配置开机自启动

    1，脚本前三行格式：

        #!/bin/sh
        #chkconfig: 2345 80 90
        #description:开机自动启动的脚本程序

    2，赋予权限，执行命令：

        cd /etc/rc.d/init.d/

        chmod +x autostart.sh

    3，添加到开机启动项，执行命令：

        chkconfig --add autostart.sh

        chkconfig autostart.sh on
