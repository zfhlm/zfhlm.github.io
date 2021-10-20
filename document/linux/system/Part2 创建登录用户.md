
#### 配置用户账号

	1，创建linux账号：
	
		useradd test
		
		passwd test
	
	2，赋予sudo权限，执行命令：
	
		su - root
	
		visudo
		
		=>
		
			root   ALL=(ALL)   ALL
			test   ALL=(ALL)   ALL
	
	3，执行命令测试权限：
	
		su - test
		
		cd /usr/local
		
		#未加sudo报权限不足错误
		mkdir backup
		
		sudo mkdir backup
		
		sudo chown test:test ./backup


