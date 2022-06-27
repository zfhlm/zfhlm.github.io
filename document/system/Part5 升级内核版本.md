
# centos 升级内核

### 升级内核

    升级内核，输入命令：

        uname -a

        ->

            3.10.0-1160.el7.x86_64

        rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

        rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm

        # 列出可安装内核
        yum --disablerepo="*" --enablerepo="elrepo-kernel" list available

        ->

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

        # 安装内核
        yum -y --enablerepo=elrepo-kernel install kernel-lt

    配置系统启动默认内核，输入命令：

        # 列出已安装内核
        awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg

        ->

            0 : CentOS Linux (5.4.201-1.el7.elrepo.x86_64) 7 (Core)
            1 : CentOS Linux (3.10.0-1160.66.1.el7.x86_64) 7 (Core)
            2 : CentOS Linux (3.10.0-1160.el7.x86_64) 7 (Core)
            3 : CentOS Linux (0-rescue-871c77eca5d3417f96c2fee453a3ca16) 7 (Core)

        # 默认 5.4.201-1.el7.elrepo.x86_64，命令参数 0
        grub2-set-default 0

        grub2-mkconfig -o /boot/grub2/grub.cfg

        reboot

    重启后进入系统查看内核信息，输入命令：

        uname -r

        ->

            5.4.201-1.el7.elrepo.x86_64
