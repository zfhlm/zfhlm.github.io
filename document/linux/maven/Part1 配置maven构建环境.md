
#### 配置maven

    1，下载maven安装包

        下载地址： https://maven.apache.org/download.cgi

        下载包： apache-maven-3.8.3-bin.tar.gz

        上传到服务器目录：/usr/local/software

    2，解压安装包，输入命令：

        cd /usr/local/software

        tar -zxvf ./apache-maven-3.8.3-bin.tar.gz

        mv ./apache-maven-3.8.3 ../

        cd ..

        ln -s ./apache-maven-3.8.3 maven

    3，更改maven配置，输入命令：

        cd /usr/local/maven

        mkdir repo

        cd ./conf

        vi setting.xml

        =>

            <localRepository>/usr/local/maven/repo</localRepository>

    4，添加系统环境变量，输入命令：

        vi /etc/profile

        =>

            export MAVEN_HOME=/usr/local/maven
            export PATH=$PATH:$MAVEN_HOME/bin

        source /etc/profile

        mvn -v
