
# 安装配置 nodejs

    下载安装包：

        下载地址：https://nodejs.org/en/download/

        选择安装包：node-v16.13.1-linux-x64.tar.xz

        上传到服务器目录： /usr/local/software

    解压安装包：

        cd /usr/local/software

        tar xf ./node-v16.13.1-linux-x64.tar.xz

        mv node-v16.13.1-linux-x64 ../

        cd ..

        ln -s ./node-v16.13.1-linux-x64/ nodejs

    配置环境变量：

        vi /etc/profile

        添加以下配置：

            export PATH=$PATH:/usr/local/nodejs/bin

        source /etc/profile

        node -v
