
# golang运行环境配置

    下载 golang，输入命令：

        cd /usr/local/software

        wget https://storage.googleapis.com/golang/go1.8.linux-amd64.tar.gz

        tar -zxvf go1.8.linux-amd64.tar.gz

        mv go ..

    配置环境变量，输入命令：

        vi /etc/profile

        =>

            export GOROOT=/usr/local/go
            export PATH=$PATH:$GOROOT/bin

        source /etc/profile

        go version

        -> go version go1.8 linux/amd64
