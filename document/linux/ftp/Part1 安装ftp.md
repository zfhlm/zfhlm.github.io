
#### 安装FTP

	安装FTP，输入命令：
	
		rpm -qa | grep vsftpd
		
		yum -y install vsftpd
		
		ll /etc/vsftpd/
		
	添加ftp账号，输入命令：
		
		mkdir -p /usr/local/file
		
		useradd -d /usr/local/file -g ftp -s /sbin/nologin ftptest
		
		passwd ftptest
		
		chown -R ftptest:ftp /usr/local/file
				
	修改 FTP 配置文件，输入命令：
	
		cd /etc/vsftpd/
		
		vi ./vsftpd.conf
		
		=>
			
			chroot_list_enable=YES
			
			chroot_list_file=/etc/vsftpd/chroot_list
			
			allow_writeable_chroot=YES
			
			pasv_enable=YES
			
			pasv_min_port=15000
			
			pasv_max_port=16000
		
		cat ./chroot_list 2>&1 | grep -q ftptest || echo ftptest >> ./chroot_list
	
	修改服务器 shell 列表，输入命令：
	
		cat /etc/shells | grep -q '/sbin/nologin' || echo '/sbin/nologin' >> /etc/shells
	
	重启 FTP 服务，输入命令：
	
		service vsftpd restart
		
	使用账号连接 FTP 服务器：
	
		连接地址：服务器IP
		
		连接端口：21
		
		连接账号：ftptest
		
		连接密码：自定义密码


