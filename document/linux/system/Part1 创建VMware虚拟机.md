
#### 新建虚拟机

    1，下载镜像文件

        访问centos官网：https://www.centos.org/download/

        找到合适版本，进入下载页面，例如：http://isoredirect.centos.org/centos/7/isos/x86_64/

        选择最小安装版本：CentOS-7-x86_64-Minimal-2009.iso

        下载到本地桌面

    2，打开VMware软件

        点击左上角【文件】-【新建虚拟机】

    3，进入虚拟机创建页面

        【您希望使用什么类型的配置】：选择【典型】

        点击【下一步】

        【安装来源】：选择【安装程序光盘映像文件(iso)】，然后选中桌面的 centos 文件

        点击【下一步】

        【虚拟机名称】：根据实际的填写，例如：CentOS 64 mysql

        【位置】：最好与名称一致，并改到非C盘，例如：D:\Virtual Machines\CentOS 64 mysql

        点击【下一步】

        【最大磁盘大小】：根据预期使用情况填写

        选中【将虚拟磁盘拆分成多个文件】

        点击【下一步】

        可以点击【自定义硬件】配置CPU核数、内存等信息

        点击【完成】

    4，介入安装过程

        等待系统安装的时候，如果提示 Enter 确认，敲击键盘 Enter，进入到界面化配置

        首先进入语言配置界面，使用 English 即可

        点击【Continue】，进入到系统安装配置界面

        【DATE & TIME】：按需点击配置，例如改为北京时区

        【KEYBOARD】：键盘配置，默认即可

        【LANGUAGE SUPPORT】：语言支持，默认即可

        【INSTALLATION SOURCE】：默认即可

        【SOFTWARE SELECTION】：默认即可

        【INSTALLATION DESTINATION】：点击之后，点击【Done】确认

        【NETWORK & HOSTNAME】：网络，点击之后，把状态改为ON，点击【Done】确认

        【SECURITY POLICY】：安全策略，默认即可

        点击【Begin Installation】进入下个界面

        【ROOT PASSWORD】：点击之后，设置root账号的密码和二次确认密码，点击【Done】确认

        然后等待安装完成

        点击【reboot】重启服务器

        至此安装完成
