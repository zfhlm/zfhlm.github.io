
# spring cloud gateway 链路追踪 skywalking

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/

        https://skywalking.apache.org/docs/skywalking-java/latest/en/setup/service-agent/java-agent/readme

        https://dlcdn.apache.org/skywalking/java-agent/8.11.0/apache-skywalking-java-agent-8.11.0.tgz (agent包下载地址)

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

  * 存在缺陷：

        网关日志无法输出 traceId，只能接入 skywalking backend 才能查看链路

### 网关 skywalking 配置

  * 解压 agent 包，更改 config/agent.config 配置：

        agent.service_name=${SW_AGENT_NAME:mrh-spring-cloud-gateway}
        agent.sample_n_per_3_secs=${SW_AGENT_SAMPLE:5}
        agent.keep_tracing=${SW_AGENT_KEEP_TRACING:true}

  * 复制 agent 包目录 optional-plugins 插件到 plugins 目录：

        apm-spring-cloud-gateway-3.x-plugin-8.11.0.jar

        apm-spring-webflux-5.x-plugin-8.11.0.jar

  * 添加 maven 依赖：

        <dependency>
            <groupId>org.apache.skywalking</groupId>
            <artifactId>apm-toolkit-trace</artifactId>
        </dependency>
        <dependency>
            <groupId>org.apache.skywalking</groupId>
            <artifactId>apm-toolkit-log4j-2.x</artifactId>
        </dependency>

  * 添加网关 VM 启动参数：

        -javaagent:/path/to/skywalking/skywalking-agent.jar
