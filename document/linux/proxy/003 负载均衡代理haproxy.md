
#### 安装准备

	1，访问地址：
	
		https://www.haproxy.org/#down
	
		找到Latest LTS version，下载安装包：haproxy-2.4.7.tar.gz
	
	2，上传到服务器目录：
	
		/usr/local/software
	
	3，准备好两台服务器：
	
		192.168.140.149
		
		192.168.140.150

#### 解压配置

	1，初始化编译环境，输入命令：
	
		yum install -y gcc-c++
	
	2，解压编译，输入命令：
	
		cd /usr/local/software
		
		tar -zxvf ./haproxy-2.4.7.tar.gz
		
		cd ./haproxy-2.4.7
		
		make TARGET=generic PREFIX=/usr/local/haproxy
		
		make install PREFIX=/usr/local/haproxy
		
		cd /usr/local/software
		
		rm -rf ./haproxy-2.4.7
	
	3，创建配置文件，输入命令：
	
		cd /usr/local/haproxy
		
		mkdir conf
		
		cd ./conf
		
		touch haproxy.cfg
	
	4，配置监控页面
		
		编辑配置文件，输入命令：
		
			cd /usr/local/haproxy
			
			vi ./conf/haproxy.cfg
		
		添加以下配置：
			
			#全局配置
			global
			#日志配置
			log 127.0.0.1 local0 info
			#最大连接数
			maxconn 1024
			#开启为后台进程  
			daemon
			#设置进程数量
			nbproc 1
			#设置pid文件位置
			pidfile /usr/local/haproxy/conf/haproxy.pid
			
			#默认配置
			defaults
			log global
			maxconn 1024
			timeout connect 5000
			timeout client 30000
			timeout server 30000
			
			#开启监听
			listen stats
			#使用http模式
			mode http
			#绑定端口
			bind *:8080
			#启用状态
			stats enable
			#隐藏版本号
			stats hide-version
			#访问uri
			stats uri /stats
			#任务账号和密码
			stats auth admin:admin
			#开启管理功能
			stats admin if TRUE
			#统计自动刷新间隔时间
			stats  refresh  30s
	
	5，启动haproxy，输入命令：
	
		/usr/local/haproxy/sbin/haproxy -f /usr/local/haproxy/conf/haproxy.cfg
		
		ps -ef | grep haproxy
	
	6，访问监控页面
	
		浏览器访问地址：http://192.168.140.149:8080/stats
		
		输入账号admin，密码admin，进入监控页面

#### 七层http负载均衡

	1，环境准备
	
		192.168.140.149		#haproxy节点一，负载均衡代理端口80
		
		192.168.140.150		#haproxy节点二，负载均衡代理端口80
		
		192.168.140.149		#tomcat应用节点一，服务端口8888
		
		192.168.140.150		#tomcat应用节点二，服务端口8888
	
	2，两台服务器配置tomcat应用
	
		安装jdk1.8并配置好环境变量
		
		tomcat安装包下载地址：https://tomcat.apache.org/download-10.cgi
		
		下载安装包：apache-tomcat-10.0.12.tar.gz
		
		上传到服务器目录：/usr/local/software
		
		解压配置tomcat，输入命令：
		
			cd /usr/local/software
			
			tar -zxvf ./apache-tomcat-10.0.12.tar.gz
			
			cd ./apache-tomcat-10.0.12/webapps
			
			rm -rf ./*
			
			mkdir ROOT
			
			#192.168.140.150 上执行命令IP地址为192.168.140.150
			echo 'tomcat 192.168.140.149' > ROOT/index.html
		
		更改运行端口，修改http端口为8888，输入命令：
		
			cd /usr/local/software/apache-tomcat-10.0.12
			
			vi ./conf/server.xml
		
		启动应用，输入命令：
		
			cd /usr/local/software/
			
			mv ./apache-tomcat-10.0.12 ../
			
			cd /usr/local/apache-tomcat-10.0.12/
			
			./bin/startup.sh
			
	3，服务器配置haproxy
		
		编辑配置文件，输入命令：
			
			cd /usr/local/haproxy
			
			vi ./conf/haproxy.cfg
		
		追加以下配置：
			
			listen websites
			bind *:80
			mode http
			log global
			maxconn 1024
			balance roundrobin
			server tomcat149 192.168.140.149:8888 check inter 2000 fall 5
			server tomcat150 192.168.140.150:8888 check inter 2000 fall 5
		
	4，重启haproxy
	
		pkill haproxy
		
		/usr/local/haproxy/sbin/haproxy -f /usr/local/haproxy/conf/haproxy.cfg
		
	5，访问测试
	
		浏览器输入以下地址：
		
			http://192.168.140.149/
			
			http://192.168.140.150/
		
		不停刷新地址，会轮询访问到两个tomcat

#### 四层tcp负载均衡

	1，环境准备
		
		192.168.140.149		#haproxy节点一，负载均衡代理端口9050
		
		192.168.140.150		#haproxy节点二，负载均衡代理端口9050
		
		192.168.140.149		#tcp应用节点一，服务端口9000
		
		192.168.140.150		#tcp应用节点二，服务端口9000
	
	2，使用springboot+maven编写发布tcp应用
		
		服务端启动类代码示例：
		
			public class NettyApplication {
			
				public static void main(String[] args) {
			
					EventLoopGroup bossGroup = new NioEventLoopGroup(1);
					EventLoopGroup workerGroup = new NioEventLoopGroup(1);
					
					try {
				        ServerBootstrap bootstrap=new ServerBootstrap();
				        bootstrap.group(bossGroup,workerGroup);
				        bootstrap.channel(NioServerSocketChannel.class);
				        bootstrap.option(ChannelOption.SO_BACKLOG, 1024);
				        bootstrap.childOption(ChannelOption.SO_KEEPALIVE, true);    
				        bootstrap.childHandler(new ChannelInitializer<SocketChannel>() {
							@Override
							protected void initChannel(SocketChannel channel) throws Exception {
								channel.pipeline().addLast(new DelimiterBasedFrameDecoder(1024,  Unpooled.wrappedBuffer("0x00".getBytes())));
								channel.pipeline().addLast(new ChannelInboundHandlerAdapter() {
								    @Override
								    public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
								        System.out.println("client msg : " +((ByteBuf) msg).toString(CharsetUtil.UTF_8));
								    }
								    @Override
								    public void channelReadComplete(ChannelHandlerContext ctx) throws Exception {
								    	String msg = "server answer from " + Arrays.stream(args).findFirst().orElse("none");
								        ctx.writeAndFlush(Unpooled.copiedBuffer(msg, CharsetUtil.UTF_8));
								    }
									@Override
									public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
										String msg = Optional.ofNullable(cause.getMessage()).orElse("系统错误!");
										ctx.writeAndFlush(Unpooled.copiedBuffer(msg, CharsetUtil.UTF_8));
										ctx.close();
									}
								});
							}
						});
				        ChannelFuture channelFuture = bootstrap.bind(9000).sync();
			            channelFuture.channel().closeFuture().sync();
					} catch (Exception e) {
						e.printStackTrace();
					} finally {
						bossGroup.shutdownGracefully();
						workerGroup.shutdownGracefully();
					}
			
				}
			
			}
		
		项目maven配置示例：
		
			<groupId>org.lushen.test</groupId>
			<artifactId>test</artifactId>
			<version>1.0.1.RELEASE</version>
		
			<properties>
				<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
				<maven-jar-plugin.version>2.6</maven-jar-plugin.version>
			</properties>
		
			<parent>
				<groupId>org.springframework.boot</groupId>
				<artifactId>spring-boot-starter-parent</artifactId>
				<version>2.1.9.RELEASE</version>
			</parent>
		
			<dependencies>
				<dependency>
					<groupId>io.netty</groupId>
					<artifactId>netty-all</artifactId>
				</dependency>
			</dependencies>
		
			<build>
				<plugins>
					<plugin>
						<groupId>org.springframework.boot</groupId>
						<artifactId>spring-boot-maven-plugin</artifactId>
					</plugin>
				</plugins>
			</build>
		
		使用maven打包，命令：
		
			mvn clean package
		
		上传到服务器，两个服务器各自的启动命令：
		
			nohup java -jar ./test-1.0.1.RELEASE.jar 192.168.140.149 &
		
			nohup java -jar ./test-1.0.1.RELEASE.jar 192.168.140.150 &
		
		编写客户端代码示例：
			
			public class NettyClient {
			
				public static void main(String[] args) {
					EventLoopGroup group = new NioEventLoopGroup(1);
					try {
						Bootstrap bootstrap = new Bootstrap();
						bootstrap.group(group);
						bootstrap.channel(NioSocketChannel.class);
						bootstrap.handler(new ChannelInitializer<SocketChannel>() {
							@Override
							protected void initChannel(SocketChannel channel) throws Exception {
								channel.pipeline().addLast(new ChannelInboundHandlerAdapter() {
								    @Override
								    public void channelActive(ChannelHandlerContext ctx) throws Exception {
								        ctx.writeAndFlush(Unpooled.copiedBuffer("connect success!0x00", CharsetUtil.UTF_8));
								    }
								    @Override
								    public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
								        System.out.println("收到服务端消息：" + ((ByteBuf) msg).toString(CharsetUtil.UTF_8));
								    }
									@Override
									public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
										cause.printStackTrace();
										ctx.close();
									}
								});
							}
						});
						ChannelFuture future = bootstrap.connect("192.168.140.149", 9000).sync();
						for(int i=0; i<1000; i++) {
							Thread.sleep(2000);
							future.channel().writeAndFlush(Unpooled.copiedBuffer("hello，i am client !0x00", CharsetUtil.UTF_8));
						}
						future.channel().close();
					} catch (Exception e) {
						e.printStackTrace();
					} finally {
						group.shutdownGracefully();
					}
				}
			
			}
		
		更改客户端代码里面的连接IP地址，启动客户端，测试连接各个服务端
	
	3，配置haproxy负载均衡
	
		更改配置文件，输入命令：
		
			cd /usr/local/haproxy
			
			vi conf/haproxy.cfg
		
		追加以下内容到配置文件：
			
			listen tcp_proxy
			mode tcp
			bind *:9050
			option tcplog
			timeout connect 5000ms
			timeout client 1800000ms
			timeout server 1800000ms
			balance roundrobin
			server proxy1 192.168.140.149:9000 check inter 2000 rise 2 fall 3
			server proxy2 192.168.140.150:9000 check inter 2000 rise 2 fall 3
			
		注意，超时时间需要根据被代理的tcp连接作配置，或者不配置超时，否则会出现连接莫名断开的问题
	
	4，重启haproxy
	
		输入命令：
		
			pkill haproxy
			
			/usr/local/haproxy/sbin/haproxy -f /usr/local/haproxy/conf/haproxy.cfg
	
	5，测试
	
		更改客户端代码里面的连接IP信息，以下随意选择一个：
		
			192.168.149.149 9050
			
			192.168.149.150 9050
		
		启动多次客户端，查看控制台输出的 服务器IP地址，可以看到连接的服务器有两台

#### 双主模式(haproxy+keepalived)

	1，安装准备

		复用四层tcp负载均衡搭建的环境
		
		双主服务器都安装好 keepalived

	2，实例相关
		
		192.168.140.149		#haproxy节点一，负载均衡代理端口9050
		
		192.168.140.150		#haproxy节点二，负载均衡代理端口9050
		
		192.168.140.149		#tcp应用节点一，服务端口9000
		
		192.168.140.150		#tcp应用节点二，服务端口9000
		
		192.168.140.202		#keepalived VIP 一
		
		192.168.140.203		#keepalived VIP 二
	
	
	





