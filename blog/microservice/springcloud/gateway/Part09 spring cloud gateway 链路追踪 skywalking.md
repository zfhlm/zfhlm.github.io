
# spring cloud gateway 链路追踪 skywalking

### 项目源码地址

    https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 官方文档地址：

    agent 包下载地址 https://dlcdn.apache.org/skywalking/java-agent/8.11.0/apache-skywalking-java-agent-8.11.0.tgz

    agent 文档地址 https://skywalking.apache.org/docs/skywalking-java/latest/en/setup/service-agent/java-agent/readme

### 网关配置

    存在问题：

        网关日志无法输出 traceId，只能接入 skywalking backend 才能查看链路

    解压 agent 包为 E:\skywalking-agent-gateway 并更改配置 config/agent.config 配置：

        agent.service_name=${SW_AGENT_NAME:mrh-spring-cloud-gateway}
        agent.sample_n_per_3_secs=${SW_AGENT_SAMPLE:5}
        agent.keep_tracing=${SW_AGENT_KEEP_TRACING:true}

    复制 agent 目录 optional-plugins 插件到 plugins 目录：

        apm-spring-cloud-gateway-3.x-plugin-8.11.0.jar

        apm-spring-webflux-5.x-plugin-8.11.0.jar

    添加 maven 依赖：

        <dependency>
            <groupId>org.apache.skywalking</groupId>
            <artifactId>apm-toolkit-trace</artifactId>
        </dependency>
        <dependency>
            <groupId>org.apache.skywalking</groupId>
            <artifactId>apm-toolkit-log4j-2.x</artifactId>
        </dependency>

    更改 log4j2 日志输出格式：

        %d{yyyy-MM-dd HH:mm:ss.SSS} %-5level %logger{36} - %msg%n

    添加服务 VM 启动参数：

        -javaagent:E:\skywalking-agent-gateway\skywalking-agent.jar

### 服务配置

    解压 agent 包为 E:\skywalking-agent-api-admin 并更改配置 config/agent.config 配置：

        agent.service_name=${SW_AGENT_NAME:mrh-spring-cloud-api-admin}
        agent.sample_n_per_3_secs=${SW_AGENT_SAMPLE:5}
        agent.keep_tracing=${SW_AGENT_KEEP_TRACING:true}

    添加 maven 依赖：

        <dependency>
            <groupId>org.apache.skywalking</groupId>
            <artifactId>apm-toolkit-trace</artifactId>
        </dependency>
        <dependency>
            <groupId>org.apache.skywalking</groupId>
            <artifactId>apm-toolkit-log4j-2.x</artifactId>
        </dependency>

    更改 log4j2 日志输出格式：

        %d{yyyy-MM-dd HH:mm:ss.SSS} %-5level %logger{36} [%traceId] [%user] - %msg%n

    添加服务 VM 启动参数：

        -javaagent:E:\skywalking-agent-api-admin\skywalking-agent.jar
