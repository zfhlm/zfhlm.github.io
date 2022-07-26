
# Oracle 单点配置

  * 以下全部基于 CentOS-7-x86_64-Minimal-2009.iso 虚拟机进行安装，虚拟机配置内存4G CPU4核

        下载地址：https://www.oracle.com/cn/database/enterprise-edition/downloads/oracle-db11g-linux.html#products

        安装包：linux.x64_11gR2_database_1of2.zip、linux.x64_11gR2_database_2of2.zip

        上传到服务器目录：/usr/local/software

### 环境配置



  * 安装依赖库，输入命令：

        yum -y install binutils compat-libstdc++-33 elfutils-libelf elfutils-libelf-devel elfutils-libelf-devel-static gcc gcc-c++ glibc glibc-common glibc-devel glibc-headers kernel-headers ksh libaio libaio-devel libgcc libgomp libstdc++ libstdc++-devel make sysstat unixODBC unixODBC-devel

  * 配置安装用户，输入命令：

        groupadd oinstall && groupadd dba

        useradd -g oinstall -G dba oracle

        passwd oracle

        chown -R oracle: /usr/local/software

  * 配置内核参数，输入命令：

        vi /etc/sysctl.conf

        =>

            fs.aio-max-nr = 1048576
            fs.file-max = 6815744
            kernel.shmall = 2097152
            kernel.shmmax = 536870912
            kernel.shmmni = 4096
            kernel.sem = 250 32000 100 128
            net.ipv4.ip_local_port_range = 9000 65500
            net.core.rmem_default = 262144
            net.core.rmem_max = 4194304
            net.core.wmem_default = 262144
            net.core.wmem_max = 1048586

        sysctl -p

  * 配置系统进程和文件句柄数限制，输入命令：

        vi /etc/security/limits.conf

        =>

            oracle soft nproc 2047
            oracle hard nproc 16384
            oracle soft nofile 1024
            oracle hard nofile 65536

  * 配置用户验证，输入命令：

        vi /etc/pam.d/login

        =>

            session    required     pam_limits.so

  * 配置环境变量，输入命令：

        vi /etc/profile

        =>

            if [ $USER = "oracle" ]; then
            if [ $SHELL = "/bin/ksh" ]; then
            ulimit -p 16384
            ulimit -n 65536
            else
            ulimit -u 16384 -n 65536
            fi
            fi

        source /etc/profile

  * 配置 hostname，输入命令：

        hostnamectl set-hostname oracle-server

        echo '192.168.140.213 oracle-server' >> /etc/hosts

  * 创建安装目录，输入命令：

        mkdir -p /home/oracle/app/oradata

        mkdir -p /home/oracle/app/oracle/product

        chown -R oracle:oinstall /home/oracle/app

  * 安装变量配置，输入命令：

        su - oracle

        vi .bash_profile

        =>

            export ORACLE_BASE=/home/oracle/app
            export ORACLE_HOME=$ORACLE_BASE/oracle/product/11.2.0/dbhome_1
            export ORACLE_SID=orcl
            export PATH=$PATH:$HOME/bin:$ORACLE_HOME/bin
            export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/usr/lib

  * 解压安装包，输入命令：

        su - oracle

        cd /usr/local/software

        unzip linux.x64_11gR2_database_1of2.zip

        unzip linux.x64_11gR2_database_2of2.zip

  * 安装桌面，输入命令：

        yum -y groupinstall "X Window System"

        yum -y groupinstall "GNOME Desktop"

  * 虚拟机进入桌面，输入命令：

        init 5

### 安装配置

  * 可视化界面打开 terminal，执行命令：

        cd /usr/local/software

        cd database

        ./runInstaller

  * 第一步，Configure Security Updates

        去除所有选择项勾选状态

        点击 Next，提示选择 Yes

  * 第二步，Installation Option

        选择 Install database software only

        点击 Next

  * 第三步，Grid Option

        选择 Single instance database installation

        点击 Next

  * 第四步，Product Languages

        点击 Next

  * 第五步，Database Edition

        选择 Enterprise Edition

        点击 Next

  * 第六步，installation Location

        默认即可

        点击 Next

  * 第七步，Create Inventory

        默认即可

        点击 Next

  * 第八步，Operating System Groups

        默认即可

        点击 Next

  * 第九步，Prerequisite Checks

        列表中未安装的依赖包使用 yum 安装

        如果依赖包版本过高检测不通过，点击 Innore all

  * 第十步，Summary

        点击 Finish

  * 第十一步，Install Product，等待安装到最后一步 pending 状态时，打开 terminal 输入命令：

        su - root

        sh /home/oracle/app/oracle/product/11.2.0/dbhome_1/root.sh

        sh /home/oracle/oraInventory/orainstRoot.sh

  * 第十二步，Finish

        至此安装完成

### 连接配置

  * 可视化界面打开 terminal 输入命令：

        netca

  * 第一步，Oracle Net Configuration Assistant: Welcome

        选择 Listener configuration

        点击 Next


  * 第二步，Oracle Net Configuration Assistant: Listener Configuration, Listener

        选择 Add

        点击 Next

  * 第三步，Oracle Net Configuration Assistant: Listener Configuration, Listener Name

        默认  LISTENER 即可

        点击 Next

  * 第四步，Oracle Net Configuration Assistant: Listener Configuration, Select Protocols

        默认 TCP 即可

        点击 Next

  * 第五步，Oracle Net Configuration Assistant: Listener Configuration, TCP/IP Protocol

        默认 Use the standard port number of 1521

        点击 Next

  * 第六步，Oracle Net Configuration Assistant: Listener Configuration, More Listeners?

        默认 No 即可

        点击 Next

  * 第七步，Oracle Net Configuration Assistant: Listener Configuration Done

        点击 Next

        下个界面点击 Finish

### 数据库配置

  * 可视化界面打开 terminal 输入命令：

        dbca

  * 第一步，Database Configuration Assistant: Welcome

        点击 Next

  * 第二步，Database Configuration Assistant，Step 1 of 12: Operations

        选择 Create a Database

        点击 Next

  * 第三步，Database Configuration Assistant，Step 2 of 12: Database Templates

        选择 Custom Database

        点击 Next

  * 第四步，Database Configuration Assistant，Step 3 of 12: Database Identification

        Golbal Database Name 填写 orcl

        SID 填写 orcl

        点击 Next

  * 第五步，Database Configuration Assistant，Step 4 of 12: Management Options

        去除勾选 Configure Enterprise Manager

        点击 Next

  * 第六步，Database Configuration Assistant，Step 5 of 12: Databse Credentials

        选择 Use the Same Administrative Password for All Accounts

        填写两次超级管理员密码

        点击 Next

  * 第七步，Database Configuration Assistant，Step 6 of 12: Database File Locations

        默认 Use Databse File Locations from Template

        点击 Next

  * 第八步，Database Configuration Assistant，Step 7 of 11: Recovery Configuration

        去除所有勾选状态

        点击 Next

  * 第九步，Database Configuration Assistant，Step 8 of 11: Database Content

        去除所有勾选状态

        点击 Next

  * 第十步，Database Configuration Assistant，Step 9 of 11: Installation Parameters

        Memory 选择 Typical，去除 Use Atomatic Memory Management 勾选状态

        Character Sets 选择 Choose from the list of Character sets，使用 UTF8 或 GBK 字符集

        点击 Next

  * 第十一步，Database Configuration Assistant，Step 10 of 11: Database Storage

        点击 Finish

  * 第十二步，Database Configuration Assistant，Step 11 of 11: Create Options

        点击 Finish

        等待完成配置

        至此全部安装配置完成，重启服务器

#### 启动数据库

  * 输入命令：

        lsnrctl status

        lsnrctl start

        sqlplus / as sysdba

        startup

        exit

#### 创建连接账号

  * 创建表空间和账号信息，输入命令：

        sqlplus / as sysdba

        create temporary tablespace test_temp tempfile '/home/oracle/app/oradata/orcl/test_temp.dbf' size 100m reuse autoextend on next 20m maxsize unlimited;

        create tablespace test datafile '/home/oracle/app/oradata/orcl/test.dbf' size 100M reuse autoextend on next 40M maxsize unlimited;

        create user test identified by 123456 default tablespace test temporary tablespace test_temp;

        grant dba to test;

  * 至此完成，使用 test/123456 连接数据库
