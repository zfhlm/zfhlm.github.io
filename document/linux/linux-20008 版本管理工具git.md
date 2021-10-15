
#### 安装git

	基于centos服务器，服务器IP地址：
	
		192.168.140.139
	
	使用yum命令安装git:
	
		yum install -y git
	
	查看git版本：
	
		git --version
	
	创建git用户：
	
		id git
		
		useradd git
		
		passwd git
	
	创建git存储父目录，即所有git仓库都建立到其子目录中：
	
		mkdir -p /home/repo
		
		cd /home/repo
		
		chmod -R g+rwX ./repo/
			
	创建git项目目录，假设项目名称为 test：
		
		cd /home/repo
		
		mkdir test.git
		
		git init --bare ./test.git
		
		chown -R git:git ./test.git

#### 客户端测试

	下载git客户端，点击运行安装，地址：
	
		https://git-for-windows.github.io/
		
	鼠标右键打开 git bash命令行，clone仓库到本地F盘：
	
		cd F:/
		
		git clone git@192.168.140.139/home/repo/test.git
	
	客户端bash可以看到输出：
	
		Cloning into 'repository'...
		git@192.168.140.139's password:
		warning: You appear to have cloned an empty repository.
		
	打开 F盘，可以看到有个test文件夹

#### 多用户配置

	创建用户分组gitgroup:
	
		groupadd gitgroup
	
	创建分组用户：
	
		useradd zhangsan
		
		passwd zhangsan
		
		useradd lisi
		
		passwd lisi
	
	添加用户到分组：
			
		usermod -G gitgroup git
		
		usermod -G gitgroup zhangsan
		
		usermod -G gitgroup lisi
		
		cat /etc/group
	
	将仓库父目录权限赋予用户组：
		
		cd /home
			
		chgrp -R gitgroup ./repo/
		
		chmod -R g+rwX ./repo/
		
	创建test项目仓库：
	
		cd /home/repo
		
		mkdir test.git
		
		chgrp -R gitgroup ./test.git
		
		chmod -R g+rwX ./test.git
		
		git init --bare ./test.git
	
	项目test仓库即创建完毕，路径： /home/repo/test.git

#### 多用户测试

	使用本地客户端，在bash客户端输入如下命令测试：
	
		cd F:\
		
		git clone git@192.168.140.139/home/repo/test.git
		
		git clone zhangsan@192.168.140.139/home/repo/test.git
		
		git clone lisi@192.168.140.139/home/repo/test.git
	
	在test文件夹随便加几个文件，使用本地客户端提交到git服务器：
	
		cd F:\test
	
		git status
		
		git add .
		
		git commit -m '测试'
		
		git push origin master

#### 禁用控制台登录

	禁止 zhangsan、lisi 两个账号的 bash 登录服务器
	
	修改用户信息配置：
	
		vi /etc/passwd
	
	更改以下信息为：
	
		zhangsan:x:1001:1002::/home/zhangsan:/usr/bin/git-shell
		lisi:x:1002:1003::/home/lisi:/usr/bin/git-shell
	
	然后保存即可.

#### 配置ssh免登陆

	1，git客户端生成秘钥，打开 Git bash:
	
		输入命令，生成ssh秘钥文件：
			
			cd ~/.ssh/
			
			ssh-keygen -t rsa
			
			键入以上命令之后，名称按提示输入 git，密码两次不输入直接回车
		
		然后在本地 ~/.ssh/ 目录会生成两个文件：
		
			公钥文件 git.pub
			
			私钥文件 git
		
	2，将私钥配置到git客户端：
		
		输入命令：
			
			cd ~/.ssh/
			
			ssh-agent bash
			
			ssh-add ./git
		
		私钥配置完成，注意：如果关闭了bash窗口，再次打开需要重复上面的命令添加 私钥
					
	3，将公钥配置到git服务端：
	
		使用记事本打开 git.pub 公钥文件，复制里面的内容为一行
		
		登录到 git 服务器，切换到 git 用户，输入命令：
		
			su - git
			
			cd ~
			
			ls -a 
		
		如果不存在 ~/.ssh/ 目录，则创建目录：
		
			mkdir .ssh
		
		进入 .ssh 目录：
		
			cd .ssh
			
			ls -a
		
		如果不存在 authorized_keys 文件，则创建文件：
		
			touch authorized_keys
		
		将 git.pub 公钥文件的内容，单独一行粘贴到 authorized_keys 文件中
		
		注意，还需要执行以下命令，否则不生效：
		
			cd ~
			
			chmod 700 -R .ssh
			
			cd ~/.ssh/
			
			chmod 600 authorized_keys
		
	4，至此完成配置，在 git bash 使用 git 用户，发现已经不用再输入密码：
	
		git clone git@192.168.140.139/home/repo/test.git

#### git基本使用

	查看目录 installer/git/ 下的 pdf 电子书

