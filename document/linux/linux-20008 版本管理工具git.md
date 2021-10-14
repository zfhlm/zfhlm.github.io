
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
	
	创建git工作目录：
	
		mkdir -p /home/git/repository
		
		cd /home/git
		
		git init --bare ./repository
		
		chown -R git:git ./repository/
	
#### 客户端测试

	下载git客户端，地址：
	
		https://git-for-windows.github.io/
	
	使用bash命令行，clone仓库到本地F盘：
	
		cd F:/
		
		mkdir git
		
		cd git
		
		git clone git@192.168.140.139:/home/git/repository
	
	客户端bash可以看到输出：
	
		Cloning into 'repository'...
		git@192.168.140.139's password:
		warning: You appear to have cloned an empty repository.
		
	切换到F盘目录，可以看到 repository 目录

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
	
	将原有的git仓库删除：
	
		cd /home/git
		
		rm -rf ./repository
		
	创建新的仓库：
	
		cd /home
		
		mkdir repository
		
		git init --bare ./repository
	
	将仓库目录权限赋予用户组：
		
		chgrp -R gitgroup /home/repository/
		
		chmod -R g+rwX ./repository/

#### 多用户测试

	使用本地客户端，在bash客户端输入如下命令测试：
	
		cd F:\
		
		mkdir git
		
		cd ./git
	
		git clone git@192.168.140.139:/home/repository
		
		git clone zhangsan@192.168.140.139:/home/repository
		
		git clone lisi@192.168.140.139:/home/repository
		
	使用本地客户端创建文件：
	
		cd ./repository
		
		mkdir test
		
		cd test
		
		echo 'test' > test.html
		
	使用本地客户端提交到git服务器：
	
		git status
		
		git add ./test
		
		git commit -m '测试'
		
		git push origin master
		
	使用本地客户端 clone git服务器文件：
	
		cd F:\
		
		mkdir repo
		
		git clone zhangsan@192.168.140.139:/home/repository/

#### 禁用控制台登录

	修改用户信息配置：

		vi /etc/passwd
	
	更改以下信息为：
	
		git:x:1000:1000::/home/git:/usr/bin/git-shell
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
	
		git clone git@192.168.140.139:/home/repository

#### git基本使用

	查看目录 installer/git/ 下的 pdf 电子书

