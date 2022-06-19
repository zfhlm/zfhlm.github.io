
#### 普通集群(搭建)

    1，集群环境预配置

        192.168.140.144

        192.168.140.145

        192.168.140.146

        三台服务器都配置好单点rabbitmq

    2，构建erlang集群环境

        停止所有rabbitmq服务，输入命令：

            cd /usr/local/rabbitmq

            ./sbin/rabbitmqctl stop

        获取某一台服务器上的erlang cookie值，输入命令：

            find / -name .erlang.cookie

            cat /root/.erlang.cookie

        修改三台服务器的 erlang cookie值(命令的值根据实际修改)，输入命令：

            echo 'WKEZLAAQAFNIENYSCMVD' > /root/.erlang.cookie

    3，配置三台服务器hosts，输入命令：

        vi /etc/hosts

        =>

            192.168.140.144    rabbit_node1
            192.168.140.145    rabbit_node2
            192.168.140.146    rabbit_node3

        service network restart

    4，启动三台服务器rabbitmq，输入命令：

        cd /usr/local/rabbitmq

        ./sbin/rabbitmq-server -detached

    5，配置rabbitmq集群

        在192.168.140.145、192.168.140.146服务器，输入命令：

            cd /usr/local/rabbitmq

            ./sbin/rabbitmqctl stop_app

            ./sbin/rabbitmqctl join_cluster rabbit@rabbit_node1

            ./sbin/rabbitmqctl start_app

            ./sbin/rabbitmqctl cluster_status

    6，查看rabbitmq集群状态

        访问管理页面 http://192.168.140.144:15672/#/

    7，测试 rabbitmq 普通集群

        springboot启动类代码示例：

            @Controller
            @RequestMapping
            @SpringBootApplication
            @ComponentScan(basePackageClasses=Application.class)
            public class Application {

                public static void main(String[] args) {
                    SpringApplication.run(Application.class, args);
                }

                @Autowired
                private RabbitTemplate rabbitTemplate;

                @GetMapping(path="/")
                @ResponseBody
                public String index() {
                    rabbitTemplate.convertAndSend(RabbitConfig.TEST_EXCHANGE, RabbitConfig.TEST_ROUTING, UUID.randomUUID().toString());
                    return "success";
                }

            }

        springboot队列和交换器配置

            @Configuration
            public class RabbitConfig {

                static final String TEST_EXCHANGE = "test.exchange";

                static final String TEST_ROUTING = "test.routing.key";

                static final String TEST_QUEUE = "test.queue";

                @Bean
                public Exchange exchange() {
                    return ExchangeBuilder.directExchange(TEST_EXCHANGE).durable(true).build();
                }

                @Bean
                public Queue queue() {
                    return QueueBuilder.durable(TEST_QUEUE).build();
                }

                @Bean
                public Binding binding() {
                    return new Binding(TEST_QUEUE, Binding.DestinationType.QUEUE, TEST_EXCHANGE, TEST_ROUTING, null);
                }

            }

        消息订阅代码示例

            @Component
            @RabbitListener(queues=RabbitConfig.TEST_QUEUE)
            public class RabbitConsumerListener {

                @RabbitHandler
                public void process(String message) {
                    System.out.println(message);
                }

            }

        springboot配置文件

            spring.rabbitmq.addresses=192.168.140.144:5672,192.168.140.144:5672,192.168.140.144:5672
            spring.rabbitmq.username=rabbitmq
            spring.rabbitmq.password=123456
            spring.rabbitmq.connection-timeout=0
            spring.rabbitmq.publisher-confirms=true
            spring.rabbitmq.publisher-returns=true

        消息发送测试，访问地址进行消息发送：http://localhost:8888/

        访问rabbitmq管理后台：http://192.168.140.144:15672/

        节点一可用的情况下，客户端发送数据全部进入节点一；节点一可用的情况下，客户端只创建了节点一的连接
