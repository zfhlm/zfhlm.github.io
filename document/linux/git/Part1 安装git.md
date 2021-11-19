
#### 安装git

    1，服务器准备

        192.168.140.139

    2，安装git，输入命令：

        yum install -y git

        git --version

#### 单用户配置

    1，创建用户，输入命令：

        id git

        useradd git

        passwd git

    2，创建项目仓库父目录，输入命令：

        mkdir -p /home/repo

        cd /home/repo

        chmod -R g+rwX ./repo/

    3，创建项目存储目录，输入命令：

        cd /home/repo

        mkdir test.git

        git init --bare ./test.git

        chown -R git:git ./test.git

    4，下载git客户端：

        下载地址 https://git-for-windows.github.io/

    5，客户端测试，打开客户端 git bash，输入命令：

        cd F:/

        git clone git@192.168.140.139/home/repo/test.git

        ->

            Cloning into 'repository'...
            git@192.168.140.139's password:
            warning: You appear to have cloned an empty repository.

#### 多用户配置

    1，配置多个用户为一个用户组，输入命令：

        groupadd gitgroup

        useradd zhangsan

        passwd zhangsan

        useradd lisi

        passwd lisi

        usermod -G gitgroup git

        usermod -G gitgroup zhangsan

        usermod -G gitgroup lisi

        cat /etc/group

    2，将仓库父目录授权给用户组，输入命令：

        chgrp -R gitgroup /home/repo/

        chmod -R g+rwX /home/repo/

    3，创建项目仓库并授权给用户组，输入命令：

        mkdir /home/repo/micro.git

        chgrp -R gitgroup /home/repo/micro.git

        chmod -R g+rwX /home/repo/micro.git

        git init --bare /home/repo/micro.git

    4，客户端打开 git bash 进行多用户测试，输入命令：

        cd F:\

        git clone git@192.168.140.139/home/repo/test.git

        git clone zhangsan@192.168.140.139/home/repo/test.git

        git clone lisi@192.168.140.139/home/repo/test.git

        cd F:\test

        git status

        git add .

        git commit -m '测试'

        git push origin master

    5，禁止用户控制台登录到git服务器，输入命令：

        vi /etc/passwd

        =>

            zhangsan:x:1001:1002::/home/zhangsan:/usr/bin/git-shell
            lisi:x:1002:1003::/home/lisi:/usr/bin/git-shell

#### ssh免登陆配置

    1，git客户端生成公钥和秘钥， 输入命令：

        cd ~/.ssh/

        ssh-keygen -t rsa

        cat ./git

        cat ./git.pub

    2，git客户端配置私钥，输入命令：

        cd ~/.ssh/

        ssh-agent bash

        ssh-add ./git

    3，git服务器配置公钥，输入命令：

        su - git

        mkdir -p  ~/.ssh/

        cd ~/.ssh/

        echo 'xxxx' >> authorized_keys        #注意把xxxx内容替换为git.pub文本内容

        cd ~

        chmod 700 -R .ssh

        cd ~/.ssh/

        chmod 600 authorized_keys

    4，git客户端测试：

        git clone git@192.168.140.139/home/repo/test.git
