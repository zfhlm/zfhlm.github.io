
#### 安装svn

    1，基于centos服务器，服务器IP地址：

        192.168.140.139

    2，使用yum命令安装svn:

        yum -y install subversion

        rpm -ql subversion

    3，创建版本仓库：

        cd /home

        mkdir -p svn/repo

        svnadmin create /home/svn/repo/

        cd svn/repo

        ll

    4，创建完毕可以看见仓库下面的目录：

        svn/repo/conf              #仓库配置文件的目录
        svn/repo/db                #版本数据库目录
        svn/repo/hooks             #版本库钩子程序目录
        svn/repo/locks             #库锁目录
        svn/repo/format            #库层次结构版本目录

#### 用户配置

    1，分配账号权限，输入命令：

        cd /home/svn/repo

        vi ./conf/authz

        =>

            # admin拥有所有根目录权限，其他人无权限
            [/]
            admin=rw
            *=

            # 各个账号在/dev目录下的的读写权限，其他人无权限
            [/dev]
            admin=rw
            zhangsan=rw
            lisi=rw
            wangwu=r
            *=

    2，分配账号密码，输入命令：

        cd /home/svn/repo

        vi ./conf/passwd

        =>

            [users]
            admin=admin
            zhangsan=123456
            lisi=123456
            wangwu=123456

    3，修改仓库服务配置，输入命令：

        cd /home/svn/repo

        vi ./conf/svnserve.conf

        =>

            #匿名用户不可读写(read/write/none)
            anon-access=none

            #授权用户可写
            auth-access=write

            #使用哪个文件作为账号文件
            password-db=passwd

            #使用哪个文件作为权限文件
            authz-db=authz

             #认证空间名，版本库所在目录
            realm=/home/svn/repo

    4，重启svn服务，输入命令：

        ps -ef | grep svn

        kill -9  进程号

        svnserve -d -r /home/svn/repo/

    5，使用不同账号连接测试以下地址：

        svn://192.168.140.139:3690/

        svn://192.168.140.139:3690/dev
