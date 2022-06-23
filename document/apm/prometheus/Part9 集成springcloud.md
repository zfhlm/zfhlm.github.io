
# prometheus 集成 springcloud 应用

### 搭建注册中心

    (任意类型注册中心，代码示例使用的是zookeeper)

### 创建 springcloud 应用

    maven 配置：

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>

        <dependency>
            <groupId>io.micrometer</groupId>
            <artifactId>micrometer-registry-prometheus</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-zookeeper-discovery</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-openfeign</artifactId>
        </dependency>
        <dependency>
            <groupId>org.apache.httpcomponents</groupId>
            <artifactId>httpclient</artifactId>
        </dependency>
        <dependency>
            <groupId>io.github.openfeign</groupId>
            <artifactId>feign-httpclient</artifactId>
        </dependency>

    application.yml 配置：

        # 容器配置
        server:
          port: 8889

        # spring boot 配置
        spring:
          application:
            name: prometheus-springcloud
          profile:
            active: default
        management:
          endpoints:
            jmx:
              exposure:
                include: "*"
            web:
              exposure:
                include: '*'
          metrics:
            tags:
              application: ${spring.application.name}

        # springcloud配置
        spring.cloud:
          zookeeper:
            enabled: true
            connect-string: 192.168.140.130:2181
            max-retries: 10
            max-sleep-ms: 500
            discovery:
              enabled: true
              register: true
              prefer-ip-address: true
              root: /cloud
              metadata:
                cluster: mrh-cluster
                service: ${spring.application.name}
        feign:
          client:
            config:
              default:
                connectTimeout: 5000
                readTimeout: 30000
          compression:
            request:
              enabled: true
              mime-types: application/json
              min-request-size: 1024
            response:
              enabled: true

    启动类：

        @SpringBootApplication
        @ComponentScan(basePackageClasses=Application.class)
        @EnableDiscoveryClient
        @EnableFeignClients(basePackageClasses={Application.class})
        public class Application {

            public static void main(String[] args) {
                SpringApplication.run(Application.class, args);
            }

        }

    启动两个 springcloud 进程，输入命令：

        cd /usr/local/app/

        nohup java -jar -Dserver.port=8889 cloud.jar &

        nohup java -jar -Dserver.port=8890 cloud.jar &

### 集成 prometheus 服务自动发现

    controller 说明：

        1，默认的 prometheus 只支持 consul 服务自动发现，使用其他注册中心需要额外扩展并部署一个转换程序，需要额外维护，且开源不一定有实现

        2，当前扩展方式，采用 http 接口去暴露集群的所有服务信息，添加一个 controller 读取注册中心所有节点信息，暴露给 prometheus 抓取，支持任何 spring cloud 设配的注册中心

        3，这里为了速度，把抓取接口放到了 spring cloud 示例应用中，实际应用可以发布在网关，然后使用 nginx 把接口代理暴露出去

    controller 代码：

        /**
         * prometheus http_sd_configs 抓取接口
         *
         * @author hlm
         */
        @RestController
        @RequestMapping(path="")
        public class PrometheusHttpSdConfigController {

            @Autowired
            private DiscoveryClient client;

            @GetMapping(path="prometheus/config/sd")
            public List<HttpSdConfig> prometheus() {

                // 获取各个服务及其集群信息
                List<String> serviceIds = client.getServices();
                List<List<ServiceInstance>> instancesGroup = serviceIds.stream().map(serviceId -> client.getInstances(serviceId)).collect(Collectors.toList());

                // 转换为 HttpSdConfig 列表
                List<HttpSdConfig> sdConfigs = instancesGroup.stream().map(instances -> {
                    List<String> targets = new ArrayList<String>();
                    Map<String, String> labels = new HashMap<String, String>();
                    instances.forEach(instance -> {
                        targets.add(instance.getHost()+":"+instance.getPort());
                        labels.putAll(instance.getMetadata());
                    });
                    return new HttpSdConfig(targets, labels);
                }).collect(Collectors.toList());

                // 返回 prometheus 需要的 JSON
                return sdConfigs;
            }

            public static class HttpSdConfig {

                private List<String> targets;

                private Map<String, String> labels;

                public HttpSdConfig(List<String> targets, Map<String, String> labels) {
                    super();
                    this.targets = targets;
                    this.labels = labels;
                }

                public List<String> getTargets() {
                    return targets;
                }

                public Map<String, String> getLabels() {
                    return labels;
                }

            }

        }

    注意，controller 添加完成之后，重新打包发布，重启应用

### 集成到 prometheus

    修改 prometheus 配置文件，输入命令：

        cd /usr/local/prometheus

        vi prometheus.yml

        =>

            scrape_configs:
              - job_name: "springcloud"
                metrics_path: /actuator/prometheus
                scheme: http
                http_sd_configs:
                  - url: http://192.168.140.130:8889/prometheus/config/sd

    重启 prometheus 进程，即完成所有配置
