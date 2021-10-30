
#### 升级内核版本
	
	更新yum源仓库，输入命令：
		
		yum -y update
		
	启用 ELRepo 仓库，输入命令：
	
		rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
		
		rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
	
	安装最新版本内核，输入命令：
		
		yum --disablerepo="*" --enablerepo="elrepo-kernel" list available
		
		yum --enablerepo=elrepo-kernel install kernel-ml
	
	配置系统默认内核，输入命令：
	
		awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
		
		grub2-set-default 0
		
		grub2-mkconfig -o /boot/grub2/grub.cfg
		
		reboot
	
	查看内核版本，输入命令：
		
		uname -r
