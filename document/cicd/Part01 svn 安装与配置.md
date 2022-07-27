
# svn 安装与配置

### svn 主流命名规范

  * 一般使用以下目录结构：

        +- <project-name>
        +  +--------- trunk
        +  +--------- branches
        +  +--------- document
        +  +--------- ...

  * 主干 trunk 只有一份，其他开发分支、bug修复分支最终都合并到主干：

        +- <project-name>
        +  +--------- trunk
        +             +---------- src/main/java
        +             +---------- src/main/resources
        +             +---------- src/test/java
        +             +---------- src/test/resources
        +             +---------- pom.xml

  * 分支 branches 有多份，分支名称团队内部统一即可，例如发布分支 x.y.z.RELEASE、开发分支 x.y.z.DEVELOP：

        +- <project-name>
        +  +--------- branches
        +             +---------- 1.0.0.RELEASE
        +             +           +---------- src/main/java
        +             +           +---------- src/main/resources
        +             +           +---------- src/test/java
        +             +           +---------- src/test/resources
        +             +           +---------- pom.xml
        +             +---------- 1.1.0.RELEASE
        +             +           +---------- src/main/java
        +             +           +---------- src/main/resources
        +             +           +---------- src/test/java
        +             +           +---------- src/test/resources
        +             +           +---------- pom.xml
        +             +---------- ...

### 安装 svn 服务

  * 使用 yum 命令安装 svn:

        yum -y install subversion

        rpm -ql subversion

  * 创建版本仓库：

        cd /home

        mkdir -p svn/repo

        svnadmin create /home/svn/repo/

        cd svn/repo

        ll

        ->

            svn/repo/conf              #仓库配置文件的目录
            svn/repo/db                #版本数据库目录
            svn/repo/hooks             #版本库钩子程序目录
            svn/repo/locks             #库锁目录
            svn/repo/format            #库层次结构版本目录

  * 分配账号权限，输入命令：

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

  * 分配账号密码，输入命令：

        cd /home/svn/repo

        vi ./conf/passwd

        =>

            [users]
            admin=admin
            zhangsan=123456
            lisi=123456
            wangwu=123456

  * 修改仓库服务配置，输入命令：

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

  * 启动或重启 svn 服务，输入命令：

        ps -ef | grep svn

        svnserve -d -r /home/svn/repo/

  * 定时备份 svn 仓库源码：

        # 可以挂载 NFS 加系统定时任务执行
        svnadmin hotcopy /home/svn/repo/ /usr/local/software/svn-backup/2022-01-01 --clean-logs

  * 使用账号连接以下地址：

        svn://192.168.140.131:3690/

        svn://192.168.140.131:3690/test
