
# skywalking 应用agent配置

### agent 包下载

    文档地址：https://skywalking.apache.org/docs/skywalking-java/latest/en/setup/service-agent/java-agent/readme/

    下载地址：https://skywalking.apache.org/downloads/

    下载包：apache-skywalking-java-agent-8.10.0.tgz

    上传到服务器目录：/usr/local/software

### agent 解压配置

    创建应用目录，输入命令：

        cd /usr/local

        mkdir app

    解压agent包，输入命令：

        cd /usr/local/software

        tar -zxvf apache-skywalking-java-agent-8.10.0.tgz

        mv ./skywalking-agent ../app/

    修改agent配置，输入命令：

        cd /usr/local/app/skywalking-agent

        vi ./config/agent.config

        =>

            # 服务名称
            agent.service_name=${SW_AGENT_NAME:test}

            # 每三秒采样条数，不用使用很大的数值，只是观察网络拓补、时延等信息
            agent.sample_n_per_3_secs=${SW_AGENT_SAMPLE:5}

            # backend不可用也保持追踪
            agent.keep_tracing=${SW_AGENT_KEEP_TRACING:true}

            # backend GRPC地址，集群多个使用逗号分隔
            collector.backend_service=${SW_AGENT_COLLECTOR_BACKEND_SERVICES:192.168.140.129:11800}

### 启动agent应用

    输入命令：

        cd /usr/local/app

        java -jar -javaagent:/usr/local/app/skywalking-agent/skywalking-agent.jar application.jar

    访问控制台查看各项指标
