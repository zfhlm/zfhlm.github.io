
# spring cloud 服务监控 prometheus

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://prometheus.io/docs/introduction/overview/

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 集成说明

  * 默认的 prometheus 只支持 consul 服务自动发现，使用其他注册中心需要额外扩展并部署一个转换程序，需要额外维护，且开源不一定有实现

  * 当前扩展方式，创建 controller 读取注册中心所有节点信息，暴露给 prometheus 抓取，支持任何 spring cloud 适配的注册中心

  * 抓取接口放到可以放到任意服务中(网关/子服务)

### 集成步骤

  * 添加 maven 依赖：

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

  * 添加 application.yml 配置：

        # 注册中心配置
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
          # 非注册中心，可以采用静态地址配置
          discovery:
            client:
              simple:
                instances:
                  mrh-spring-cloud-api-simple:
                  - uri: http://localhost:9529
                  - uri: http://localhost:9530
                  - uri: http://localhost:9531
                  mrh-spring-cloud-api-admin:
                  - uri: http://localhost:9550
                  - uri: http://localhost:9551
                  - uri: http://localhost:9552
    启动类：

        @SpringBootApplication
        @ComponentScan(basePackageClasses=Application.class)
        @EnableFeignClients(basePackageClasses={Application.class})
        public class Application {

            public static void main(String[] args) {
                SpringApplication.run(Application.class, args);
            }

        }

  * 创建 prometheus http_sd_configs 抓取接口

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

  * 添加 prometheus 抓取配置：

        scrape_configs:
          - job_name: "springcloud"
            metrics_path: /actuator/prometheus
            scheme: http
            http_sd_configs:
              - url: http://192.168.140.130:8889/prometheus/config/sd
