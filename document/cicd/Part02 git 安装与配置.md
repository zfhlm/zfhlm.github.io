
# git 安装与配置

### 安装 git 服务

  * 输入命令：

        yum install -y git

        git --version

        ->

            git version 1.8.3.1

### 分配 git 账号

  * 配置多个用户为一个用户组，输入命令：

        # 创建用户组
        groupadd gitgroup

        # 创建三个用户

        useradd zhangsan

        passwd zhangsan

        useradd lisi

        passwd lisi

        useradd git

        passwd git

        # 将用户添加到用户组

        usermod -G gitgroup git

        usermod -G gitgroup zhangsan

        usermod -G gitgroup lisi

        cat /etc/group

  * 禁止用户 ssh 登录 git 服务器，输入命令：

        ll /bin/git-shell

        vi /etc/passwd

        =>

            zhangsan:x:1001:1002::/home/zhangsan:/bin/git-shell
            lisi:x:1002:1003::/home/lisi:/bin/git-shell

  * 将仓库父目录授权给用户组，输入命令：

        mkdir -p /home/repo/

        chgrp -R gitgroup /home/repo/

        chmod -R g+rwX /home/repo/

  * 创建项目仓库并授权给用户组，输入命令：

        mkdir /home/repo/test.git

        chgrp -R gitgroup /home/repo/test.git

        chmod -R g+rwX /home/repo/test.git

        git init --bare /home/repo/test.git

  * 客户端打开 git bash 进行多用户测试，输入命令：

        # clone git 仓库

        cd F:\

        git clone ssh://git@192.168.140.131/home/repo/test.git

        # commit git 仓库

        cd F:\test

        echo 'test' > test.log

        git status

        git add .

        git config --global user.name git

        git config --global user.email '914589210@qq.com'

        git commit -m '测试'

        git push origin master

### 配置 git 免登陆

  * 注意，免密登录账号，不能禁止其 ssh 登录功能

  * git 客户端生成公钥和秘钥， 输入命令：

        cd ~/.ssh/

        # 输入 git 然后两次回车
        ssh-keygen -t rsa

        cat ./git

        cat ./git.pub

  * git 客户端配置私钥，输入命令：

        cd ~/.ssh/

        ssh-agent bash

        ssh-add ./git

  * git 服务器配置公钥，输入命令：

        su - git

        mkdir -p  ~/.ssh/

        cd ~/.ssh/

        # 注意把 xxxx 内容替换为 git.pub 文本内容
        echo 'xxxx' >> authorized_keys

        cd ~

        chmod 700 -R .ssh

        cd ~/.ssh/

        chmod 600 authorized_keys

  * git 客户端测试：

        git clone ssh://git@192.168.140.131/home/repo/test.git

        -> 如果本地没有 authorized_keys 文件，Are you sure you want to continue connecting (yes/no)? yes 后续不会再有确认信息
