
# redis 集群管理工具 redisinsight

### 安装 redisinsight

    使用 docker 安装，输入命令：

        mkdir /usr/local/redisinsight

        chown -R 1001 /usr/local/redisinsight

        docker pull redislabs/redisinsight:1.12.0

        # 此处使用 host 网络，方便跨主机访问 redis 实例
        docker run -it -d -v /usr/local/redisinsight:/db --restart always --network host --name redisinsight redislabs/redisinsight:1.12.0

    访问 web 管理界面：

        http://192.168.140.160:8001

### 使用 redisinsight

    添加单节点 redis 或 rediscluster：

        首页点击【Add redis database】

        选择【Connect to a redis database】

        填写【host】集群任意节点 IP 地址

        填写【port】节点端口

        填写【name】自定义集群在管理后台显示的名称

        填写【password】集群各节点配置的访问密码

        点击【Add redis database】至此完成引导添加数据源

    首页点击刚刚添加的数据源，进入管理页面，即可查看各项统计信息，执行cli命令，集群节点的动态添加/移除等
