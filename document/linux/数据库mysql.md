
### 单点配置

	1，下载安装包
	
		下载地址：https://downloads.mysql.com/archives/community/
		
		下载安装包：Compressed TAR Archive mysql-5.7.35-linux-glibc2.12-x86_64.tar.gz
		
		上传到服务器目录：/usr/local/software
		
	2，解压到安装目录，输入命令：
		
		rpm -qa | grep mariadb
		
		rpm -e --nodeps mariadb-libs-5.5.68-1.el7.x86_64
		
		cd /usr/loca/software
		
		tar -zxvf ./mysql-5.7.35-linux-glibc2.12-x86_64.tar.gz
		
		mv mysql-5.7.35-linux-glibc2.12-x86_64 ../mysql-5.7.35
		
		cd ..
		
		ln -s mysql-5.7.35 mysql
		
	3，配置数据库启动账号，输入命令：
		
		groupadd mysql
		
		useradd -r -s /sbin/nologin -g mysql mysql -d /usr/local/mysql/
		
		chown -R mysql:mysql /usr/local/mysql
		
		chown -R mysql:mysql /usr/local/mysql/
	
	4，初始化数据库，输入命令：
		
		cd /usr/local/mysql
		
		./bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql/ --datadir=/usr/local/mysql/data/
		
		-> 执行完毕控制台会输出密码，需要记住密码文本
		
		vi /etc/my.cnf
		
		=> (查看目录installer/mysql/my.cnf)
		
		mkdir log
		
		touch ./log/mysql.log
		
		chown -R mysql:mysql ./log
		
		vi /etc/profile
		
		=>
			
			export MYSQL_HOME="/usr/local/mysql/"
			
			export PATH="$PATH:$MYSQL_HOME/bin"
			
		source /etc/profile
		
	5，启动数据库，输入命令：
		
		cd /usr/local/mysql
		
		cp -a ./support-files/mysql.server /etc/init.d/mysqld
		
		service mysqld start
	
	6，初始化远程超管账号，输入命令：
		
		mysql -uroot -p
		
		==>
			
			set PASSWORD = PASSWORD('123456');
			
			flush privileges;
			
			use mysql;
			
			update user set host='%' where user='root';
			
			grant all privileges on *.* to 'root'@'%' identified by '123456';
			
			flush privileges;
			
		service mysqld restart

### 
		
		
		
		
