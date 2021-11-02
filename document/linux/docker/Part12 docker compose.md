
# docker compose

	docker compose 用于定义和运行多容器Docker应用程序的工具，使用 yaml 文件进行容器编排

	注意，只有 docker compose 而不配合 docker swarm 只能实现单主机容器编排

	官方文档：

		https://docs.docker.com/compose/

		https://github.com/compose-spec/compose-spec/blob/master/spec.md

### 下载安装

	下载执行脚本，输入命令：

		cd /usr/local/software

		wget -O docker-compose https://github.com/docker/compose/releases/download/v2.0.1/docker-compose-linux-x86_64

	配置执行脚本，输入命令：

		mkdir -p /usr/lib/docker/cli-plugins/

		mv ./docker-compose /usr/lib/docker/cli-plugins/

		chmod +x /usr/lib/docker/cli-plugins/docker-compose

		ln -s /usr/lib/docker/cli-plugins/docker-compose /usr/bin/docker-compose

	查看是否成功，输入命令：

		docker-compose --version

		-> Docker Compose version v2.0.1

### docker compose 配置

	docker compose 配置文件名称：

		compose.yaml

		compose.yml

	docker compose 配置文件顶层由以下几部分组成：

		version           # 定义验证配置文件版本号

		volumes           # 定义容器可用的挂载目录(可选)

		configs           # 定义容器可用的运行配置文件(可选)

		secrets           # 定义容器可用的敏感信息，如密码、证书等(可选)

		networks          # 定义容器可用的网络配置(可选)

		services          # 定义从打包镜像到运行容器的配置

	以上配置，networks、volumes、configs、secrets 定义以后，供给最核心配置 services 引用

### docker compose version 配置

	根据 docker 引擎的版本填写，对应的关系如下：

		3.8 => 19.03.0+
		3.7 => 18.06.0+
		3.6 => 18.02.0+
		3.5 => 17.12.0+
		3.4 => 17.09.0+
		3.3 => 17.06.0+
		3.2 => 17.04.0+
		3.1 => 1.13.1+
		3.0 => 1.13.0+
		2.4 => 17.12.0+
		2.3 => 17.06.0+
		2.2 => 1.13.0+
		2.1 => 1.12.0+
		2.0 => 1.10.0+

	在 docker compose 宿主机输入命令确定 docker 引擎版本号，输入命令：

		docker --version

		-> Docker version 20.10.10, build b485636

	如果当前本机版本号 20.10.10，使用以下配置：

		version: '3.8'

### docker compose volumes 配置

	定义多个挂载目录参数格式：

		volumes:
		  <volume-name>:
		    name: <name>
		    driver: <driver>
		    driver_opts:
		      - <key>=<value>
		      - ...
		    external: <boolean>
		    labels:
		      - <key>=<value>
		      - <key>=<value>
		      - ...
		      - <key>=<value>
		  <volume-name>:
		   ...

	各个参数含义：

		name              # 挂载目录引用名称

		driver            # 挂载目录驱动

		driver_opts       # 挂载目录驱动参数

		external          # 挂载目录是否已存在

		labels            # 挂载目录元数据

### docker compose configs 配置

	定义多个外部配置文件，整体参数格式：

		configs:
		  <config-name>:
		    file: <path>
		    external: <boolean>
		    name: <name>
		  ...

	各个参数含义：

		file              # 配置文件位置

		external          # 配置文件是否已存在

		name              # 配置文件引用名称

### docker compose secrets 配置

	定义多个外部敏感信息文件，整体参数格式：

		secrets:
		  <secret-name>:
		    file: <path>
		    external: <boolean>
		    name: <name>
		  ...

	各个参数含义：

		file              # 敏感信息文件位置

		external          # 敏感信息文件是否已存在

		name              # 敏感信息文件引用名称

### docker compose networks 配置

	定义多个不同的网络，格式：

		networks:
		  <net-name>:
		  <net-name>:
		     ...
		  <net-name>:

	参数 driver 用于定义网络网卡 driver，必须为合法的 driver，格式：

		networks:
		  <net-name>:
		    driver: <driver-name>

	参数 name 用于定义网络名称，格式：

		networks:
		  <net-name>:
		    name: <network>

	参数 driver_opts 定义传递给网卡驱动参数，格式：

		networks:
		  <net-name>:
		    driver_opts:
		      - <name>=<value>
		      - <name>=<value>
		      -  ...
		      - <name>=<value>

	参数 attachable 定义是否网络可以连接的，格式：

		networks:
		  <net-name>:
		    attachable: <boolean>

	参数 enable_ipv6 定义是否网络启用 ipv6，格式：

		networks:
		  <net-name>:
		    enable_ipv6: <boolean>

	参数 ipam 定义网络地址管理(ip address manage)，ipam包含多个子配置：

		ipam.driver                  #网络驱动
		ipam.config.subnet           #网段
		ipam.config.ip_range         #分配IP段
		ipam.config.gateway          #网关
		ipam.config.aux_addresses    #备用IP列表
		ipam.options                 #网络驱动参数

		networks:
		  <net-name>:
		    ipam:
		      driver: <driver>
		      config:
		        - subnet: <subnet>
		          ip_range: <ip_range>
		          gateway: <gateway>
		          aux_addresses: <aux_addresses>
		      options:
		        <name>: <value>
		        <name>: <value>
		        ...
		        <name>: <value>

	参数 internal 定义是否允许创建内部隔离网络，格式：

		networks:
		  internal: <boolean>

	参数 external 定义是否已存在的外部网络，格式：

		networks:
		  external: <boolean>

	参数 labels 定义元信息，格式：

		networks:
		  labels:
		    - <name>=<value>
		    - <name>=<value>
		    - ...
		    - <name>=<value>

### yaml services

	定义多个编排服务，格式：

		services:
		  <service-name>:
		  <service-name>:
			...

		# 示例
		services:
		  mysql:
			redis:
			application:
			nginx:

	参数 build 定义 Dockerfile 文件位置，格式：

		services:
		  <service-name>:
			  build: <path>

		services:
		  <service-name>:
		    build:
		      context: <path>
		      dockerfile: <Dockerfile-name>
		      args:
		        <key>: <value>
		        <key>: <value>
						...
		      labels:
		        <key>: <value>
		        <key>: <value>
						...
		      target: <taget>

		# 示例
		service:
		  springboot:
			  build: .

	参数 image 定义镜像名称，格式：

		services:
			<service-name>:
				image: <image-name>

	参数 container_name 定义容器名称，格式：

		services:
		  <service-name>:
			  container_name: <container_name>

	参数 depends_on 定义启动依赖服务，格式：

		services:
			<service-name>:
				depends_on:
				  - <other-service-name>
				  - <other-service-name>
					...

	参数 networks 定义容器网络，引用 networks 配置，格式：

		services:
		  <service-name>:
			  networks:
				  - <network>
				  - <network>
					...

	参数 restart 定义容器在 docker 重启后的行为，格式：

		services:
		  <service-name>:
			  restart: <restart>

		可用参数值：no、always、on-failure、unless-stopped

	参数 volumes 定义容器挂载目录，格式：

		services:
			<service-name>:
				- <volume>
				- <volume>
				...

	参数 ulimits 定义容器文件句柄和线程限制，格式：

			services:
				<service-name>:
					ulimits:
						nproc: <limit>
						nofile:
							soft: <limit>
							hard: <limit>

	更多配置信息，参考 GitHub 官方文档

### docker compose 使用

	使用 docker compose 编排两个容器：redis、springboot

	springboot 启动类：

		@Controller
		@RequestMapping
		@SpringBootApplication
		public class Application {

			public static void main(String[] args) {
				SpringApplication.run(Application.class, args);
			}

			@Autowired
			private RedisTemplate<String, String> redisTemplate;

			@GetMapping(path="/")
			@ResponseBody
			public String index() {
				redisTemplate.opsForValue().set("key", UUID.randomUUID().toString());
				return redisTemplate.opsForValue().get("key");
			}

		}

	springboot 配置文件 application.properties：

		server.port=8888
		spring.redis.host=redis
		spring.redis.port=6379

	springboot maven 配置 pom.xml：

		<parent>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-parent</artifactId>
			<version>2.5.5</version>
		</parent>

		<dependencies>
			<dependency>
				<groupId>org.springframework.boot</groupId>
				<artifactId>spring-boot-starter-web</artifactId>
			</dependency>
			<dependency>
				<groupId>org.springframework.boot</groupId>
				<artifactId>spring-boot-starter-data-redis</artifactId>
			</dependency>
		</dependencies>

		<build>
			<finalName>application</finalName>
			<plugins>
				<plugin>
					<groupId>org.springframework.boot</groupId>
					<artifactId>spring-boot-maven-plugin</artifactId>
					<configuration>
						<layers>
							<enabled>true</enabled>
						</layers>
					</configuration>
				</plugin>
			</plugins>
		</build>

	springboot 项目根目录创建 Dockerfile，填写以下指令：

		FROM openjdk
		WORKDIR /usr/local/application/
		COPY target/application.jar application.jar
		EXPOSE 8888
		ENTRYPOINT ["java", "-jar","/usr/local/application/application.jar"]

	将 springboot 项目命名为 test 上传到 /usr/local/compose/ 目录，执行打包命令：

		cd test

		mvn clean package

	编写 docker compose 配置文件：

		cd /usr/local/compose/

		vi compose.yml

	添加以下内容：

		version: '3.8'
		services:
		  redis:
		    image: redis
		    container_name: redis
		  application:
		    build: ./test/
		    image: application:1.0
		    container_name: application

	执行编排任务，输入命令：

		docker-compose up -d

		docker inspect application

	访问 springboot 接口，输入命令：

		curl http://hostname:8888
