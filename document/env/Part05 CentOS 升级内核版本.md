
# centos 升级内核版本

  * 官方文档地址：

        http://elrepo.org/tiki/HomePage

        http://elrepo.reloumirrors.net/kernel/

### 升级最新版本内核

  * 如有必要，更新所有依赖包：

        # 谨慎使用 -y 可能会影响已运行服务
        yum update -y

  * 查看当前内核版本，输入命令：

        uname -r

        ->

            3.10.0-1160.el7.x86_64

  * 安装 rpm 内核包管理工具，输入命令：

        rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

        rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm

  * 查看 rpm 提供的内核版本，输入命令：

        yum --disablerepo="*" --enablerepo="elrepo-kernel" list available

        ->  ( 主线最新版本 ml，长期支持版本 lt )

            kernel-lt-devel.x86_64                                                                 5.4.201-1.el7.elrepo                                                      elrepo-kernel
            kernel-lt-doc.noarch                                                                   5.4.201-1.el7.elrepo                                                      elrepo-kernel
            kernel-lt-headers.x86_64                                                               5.4.201-1.el7.elrepo                                                      elrepo-kernel
            kernel-lt-tools.x86_64                                                                 5.4.201-1.el7.elrepo                                                      elrepo-kernel
            kernel-lt-tools-libs.x86_64                                                            5.4.201-1.el7.elrepo                                                      elrepo-kernel
            kernel-lt-tools-libs-devel.x86_64                                                      5.4.201-1.el7.elrepo                                                      elrepo-kernel
            kernel-ml.x86_64                                                                       5.18.7-1.el7.elrepo                                                       elrepo-kernel
            kernel-ml-devel.x86_64                                                                 5.18.7-1.el7.elrepo                                                       elrepo-kernel
            kernel-ml-doc.noarch                                                                   5.18.7-1.el7.elrepo                                                       elrepo-kernel
            kernel-ml-headers.x86_64                                                               5.18.7-1.el7.elrepo                                                       elrepo-kernel
            kernel-ml-tools.x86_64                                                                 5.18.7-1.el7.elrepo                                                       elrepo-kernel
            kernel-ml-tools-libs.x86_64                                                            5.18.7-1.el7.elrepo                                                       elrepo-kernel
            kernel-ml-tools-libs-devel.x86_64                                                      5.18.7-1.el7.elrepo                                                       elrepo-kernel

  * 安装 lt 版本内核，输入命令：

        # 安装内核
        yum -y --enablerepo=elrepo-kernel install kernel-lt kernel-lt-devel

        # 列出已安装内核
        awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg

        ->

            0 : CentOS Linux (5.4.201-1.el7.elrepo.x86_64) 7 (Core)
            1 : CentOS Linux (3.10.0-1160.66.1.el7.x86_64) 7 (Core)
            2 : CentOS Linux (3.10.0-1160.el7.x86_64) 7 (Core)
            3 : CentOS Linux (0-rescue-871c77eca5d3417f96c2fee453a3ca16) 7 (Core)

        # 配置 5.4.201-1.el7.elrepo.x86_64 为开机启动默认内核
        grub2-set-default 0

        # 使开机启动配置生效
        grub2-mkconfig -o /boot/grub2/grub.cfg

        # 重启
        reboot

  * 重启后，系统查看内核信息，输入命令：

        uname -r

        ->

            5.4.201-1.el7.elrepo.x86_64
