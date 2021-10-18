
#### 安装准备

	访问地址：https://www.rabbitmq.com/news.html
	
	查看最新版本 RabbitMQ 3.9.7 release24 描述：
	
		This release requires Erlang/OTP 23.2 and supports Erlang 24.
	
	该安装包依赖 Erlang 23.2版本
	
	假设服务器IP地址：192.168.140.144

#### 安装erlang

	1，下载安装包
	
		地址：https://www.erlang.org/downloads
		
		下载包：otp_src_23.2.tar.gz
		
		下载完成上传到服务器目录：/usr/local/software
	
	2，安装依赖库，输入命令：
		
		yum -y install make gcc gcc-c++ kernel-devel m4 ncurses-devel openssl-devel 
		
		yum -y install unixODBC-devel libtool libtool-ltdl-devel
	
	3，解压配置：
	
		输入命令：
		
			cd /usr/local/software
			
			tar -zxvf ./otp_src_23.2.tar.gz
			
			cd ./otp_src_23.2
			
			./configure --prefix=/usr/local/erlang-23.2 --without-javac
			
			make && make install
			
			cd ..
			
			rm -rf ./otp_src_23.2
			
			cd /usr/local
			
			ln -s ./erlang-23.2 erlang
		
		配置环境变量，输入命令：
		
			vi /etc/profile
			
			添加以下信息：
				
				export PATH=$PATH:/usr/local/erlang/bin
			
			source /etc/profile
		
	4，测试是否配置成功：
	
		输入命令：
		
			erl -version
		
		输出如下信息安装成功：
		
			Erlang (SMP,ASYNC_THREADS,HIPE) (BEAM) emulator version 11.1.4

#### 安装rabbitmq

	1，下载安装包：
	
		地址：https://github.com/rabbitmq/rabbitmq-server/releases
		
		下载包：rabbitmq-server-generic-unix-3.9.7.tar.xz
		
		下载完成上传到服务器目录：/usr/local/software
	
	2，解压配置：
	
		输入命令：
		
			cd /usr/local/software
			
			tar -xvf ./rabbitmq-server-generic-unix-3.9.7.tar.xz
			
			mv ./rabbitmq_server-3.9.7/ ../
			
			cd ..
			
			ln -s ./rabbitmq_server-3.9.7 rabbitmq
	
	3，启动与停止：
	
		启动命令：
		
			./sbin/rabbitmq-server -detached
		
		停止命令：
		
			./sbin/rabbitmqctl stop
	
	4，用户配置：
		
		创建用户rabbitmq/123456，输入命令：
			
			./sbin/rabbitmqctl add_user rabbitmq 123456
		
		配置rabbitmq管理员权限：
		
			./sbin/rabbitmqctl set_user_tags rabbitmq administrator
			
			./sbin/rabbitmqctl set_permissions -p / rabbitmq '.*' '.*' '.*'
	
	5，开启web管理界面：
		
		输入命令，启用管理界面相关插件(注意，只需执行一次命令，后面不需要再执行)：
		
			./sbin/rabbitmq-plugins enable rabbitmq_management
				
		访问管理界面，使用刚刚创建的rabbitmq账号登录：
		
			http://192.168.140.144:15672/

#### 配置文件

	最新版本的rabbitmq没有自带配置文件，需要自己下载
	
	1，访问官方文档地址：
	
		https://www.rabbitmq.com/configure.html#config-file
		
	2，浏览之后找到示例配置文件下载地址：
	
		https://github.com/rabbitmq/rabbitmq-server/blob/v3.8.x/deps/rabbit/docs/rabbitmq.conf.example
	
	3，服务器输入命令下载：
	
		cd /usr/local/rabbitmq
		
		wget https://github.com/rabbitmq/rabbitmq-server/blob/v3.8.x/deps/rabbit/docs/rabbitmq.conf.example
		
		cp rabbitmq.conf.example rabbitmq.conf
	
	4，重启rabbitmq，输入命令：
	
		./sbin/rabbitmqctl stop
		
		./sbin/rabbitmq-server -detached

#### 安装插件

	假设需要安装延迟队列插件：rabbitmq_delayed_message_exchange
	
	访问地址获取插件下载相关信息：https://www.rabbitmq.com/community-plugins.html
	
	1，下载插件
	
		下载地址：https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/releases
		
		下载文件：rabbitmq_delayed_message_exchange-3.9.0.ez
		
		下载完成上传到rabbitmq插件目录：/usr/local/rabbitmq/plugins
	
	2，启用插件：
	
		输入命令：
		
			cd /usr/local/rabbitmq
			
			./sbin/rabbitmq-plugins enable rabbitmq_delayed_message_exchange
		
		至此完成插件配置

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
		
	3，配置三台服务器hosts
	
		输入命令：
	
			vi /etc/hosts
		
		加入以下内容：
		
			192.168.140.144	rabbit_node1
			192.168.140.145	rabbit_node2
			192.168.140.146	rabbit_node3
		
		重启网卡，输入命令：
		
			service network restart
	
	4，启动三台服务器rabbitmq
	
		输入命令：
			
			cd /usr/local/rabbitmq
			
			./sbin/rabbitmq-server -detached
		
	5，配置rabbitmq集群
	
		在192.168.140.145、192.168.140.146服务器，输入命令：
		
			cd /usr/local/rabbitmq
			
			./sbin/rabbitmqctl stop_app
			
			./sbin/rabbitmqctl join_cluster rabbit@rabbit_node1
			
			./sbin/rabbitmqctl start_app
		
		查看集群状态，输入命令：
		
			./sbin/rabbitmqctl cluster_status
		
		访问管理页面，可以查看集群状态：
		
			http://192.168.140.144:15672/#/

#### 普通集群(测试)

	考虑rabbitmq集成问题，使用springboot项目进行测试
	
	1，springboot启动类代码示例：
		
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
		
	2，springboot队列和交换器配置
		
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
	
	3，消息订阅代码示例
	
		@Component
		@RabbitListener(queues=RabbitConfig.TEST_QUEUE)
		public class RabbitConsumerListener {
		
			@RabbitHandler
			public void process(String message) {
				System.out.println(message);
			}
		
		}
	
	4，springboot配置文件
	
		spring.rabbitmq.addresses=192.168.140.144:5672,192.168.140.144:5672,192.168.140.144:5672
		spring.rabbitmq.username=rabbitmq
		spring.rabbitmq.password=123456
		spring.rabbitmq.connection-timeout=0
		spring.rabbitmq.publisher-confirms=true
		spring.rabbitmq.publisher-returns=true
	
	5，消息发送测试
	
		访问地址进行消息发送：
		
			http://localhost:8888/
		
		访问rabbitmq管理后台：
		
			http://192.168.140.144:15672/
			
			http://192.168.140.145:15672/
			
			http://192.168.140.146:15672/
	
	6，存在的问题
	
		节点一可用的情况下，客户端发送数据全部进入节点一
		
		节点一可用的情况下，客户端只创建了节点一的连接

#### 镜像集群(搭建)

	1，环境准备
	
		镜像集群基于普通集群进行配置
	
	2，配置镜像集群
	
		输入命令：
			
			cd /usr/local/rabbitmq
			
			./sbin/rabbitmqctl set_policy ha-all "^" '{"ha-mode":"all"}'
		
		参数含义：
		
			ha-all			#自定义策略名称
			
			^				#匹配符，^代表匹配所有
			
			ha-mode		#匹配类型，共3种模式：all-所有，exctly-部分，nodes-指定
	
	3，登录管理后台查看
	
		各个节点都有了如下信息：
		
			Name                 Node                     Type      Features	
			test.assign.queue    rabbit@rabbit_node1 +2   classic   D DLX DLK ha-all
			test.fallback.queue  rabbit@rabbit_node1 +2   classic   D ha-all idle	
	
	6，存在的问题
	
		节点一可用的情况下，客户端发送数据全部进入节点一，然后数据被异步复制到其他节点
		
		节点一可用的情况下，客户端只创建了节点一的连接

#### 高可用集群(haproxy+keepalived)

	1，环境准备
		
		提前配置好 rabbitmq 镜像集群和 haproxy+keepalived 双主模式
		
		rabbitmq 镜像集群服务器：
			
			192.168.140.144		#rabbitmq集群节点一
			
			192.168.140.145		#rabbitmq集群节点二
			
			192.168.140.146		#rabbitmq集群节点三
				
		haproxy+keepalived 双主模式服务器：
			
			192.168.140.149		#haproxy节点一，代理端口5672
			
			192.168.140.150		#haproxy节点二，代理端口5672
			
			192.168.140.202		#keepalived VIP 一
			
			192.168.140.203		#keepalived VIP 二
	
	2，配置haproxy负载均衡
		
		注意，如果配置了tcp连接超时，因为超时时间导致haproxy断开rabbitmq连接的问题，通常不配置超时时间，或者配置一个较大的超时时间
		
		修改haproxy配置：
		
			cd /usr/local/haproxy
			
			vi conf/haproxy.cfg
		
		加入以下配置内容：
			
			listen stats
			bind *:8888
			mode http
			log 127.0.0.1 local3 err
			stats refresh 60s
			stats uri /stats
			stats realm Haproxy
			stats auth admin:123456
			stats hide-version
			stats admin if TRUE
			
			listen rabbitmq_cluster
			bind *:5672
			mode tcp
			balance roundrobin
			server rabbitnode1 192.168.140.144:5672 check inter 2000 rise 2 fall 3 weight 1
			server rabbitnode2 192.168.140.145:5672 check inter 2000 rise 2 fall 3 weight 1
			server rabbitnode3 192.168.140.146:5672 check inter 2000 rise 2 fall 3 weight 1
	
	3，客户端连接
	
		修改连接IP地址为两个VIP地址即可：
		
			spring.rabbitmq.addresses=192.168.140.202:5672,192.168.140.203:5672
			spring.rabbitmq.username=rabbitmq
			spring.rabbitmq.password=123456
			spring.rabbitmq.connection-timeout=0
			spring.rabbitmq.publisher-confirms=true
			spring.rabbitmq.publisher-returns=true
	
	4，测试
	
		使用普通集群的客户端进行测试即可






