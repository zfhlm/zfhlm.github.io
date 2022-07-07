
# spring cloud bus 自定义事件通知

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-bus/docs/current/reference/html/

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 自定义事件

  * 创建远程事件实现类：

        public class TestRemoteEvent extends RemoteApplicationEvent {

            private static final long serialVersionUID = 1788794459100508149L;

            @SuppressWarnings("unused")
            private TestRemoteEvent() {
                super();
            }

            public TestRemoteEvent(Object source, String originService, Destination destination) {
                super(source, originService, destination);
            }

        }

  * 启动类添加远程事件扫描注解

        @RemoteApplicationEventScan(basePackageClasses=TestRemoteEvent.class)

  * 创建事件发布测试接口：

        @Autowired
        private ApplicationContext context;
        @Autowired
        private BusProperties busProperties;
        @Autowired
        private Destination.Factory destinationFactory;

        @GetMapping(path="publish")
        public String publish() {
            // 此处 destination 定义为全部 bus 服务，可以定义为 <spring.application.name> 或 <spring.application.name>:<server.port>
            context.publishEvent(new TestRemoteEvent(this, busProperties.getId(), destinationFactory.getDestination(null)));
            return "success";
        }

  * 启动三个服务实例，请求任意一个服务实例接口：

        http://localhost:9537/publish

        -> 可以看到三个实例控制台输出：

            [TestRemoteEvent@610e0c0e id = '51c95447-5f68-4ae8-b96d-8fe99710b908', originService = 'mrh-spring-cloud-service-bus-amqp:9537:3b879ca9428e0b507464f17d35020bda', destinationService = '**']
            ...
            [AckRemoteApplicationEvent@5ccb5d7b id = 'c8dadabd-8124-4c00-babc-3addb82dad9e', originService = 'mrh-spring-cloud-service-bus-amqp:9539:58f5d484bdf8f1bd3148cf798fc1f69d', destinationService = '**']
