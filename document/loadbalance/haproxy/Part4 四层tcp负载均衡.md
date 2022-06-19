
# haproxy 四层 tcp 负载均衡

### 环境准备
		
	192.168.140.149		#haproxy节点一，负载均衡代理端口9050
	
	192.168.140.150		#haproxy节点二，负载均衡代理端口9050
	
	192.168.140.149		#tcp应用节点一，服务端口9000
	
	192.168.140.150		#tcp应用节点二，服务端口9000
	
### 使用springboot+maven编写发布tcp应用
		
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
	
### 配置haproxy负载均衡
	
	更改配置文件，输入命令：
	
		cd /usr/local/haproxy
		
		vi conf/haproxy.cfg
		
		=>
			
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
			
		#注意，超时时间需要根据被代理的tcp连接作配置，或者不配置超时，否则会出现连接莫名断开的问题
	
### 重启haproxy
	
	输入命令：
	
		pkill haproxy
		
		/usr/local/haproxy/sbin/haproxy -f /usr/local/haproxy/conf/haproxy.cfg
	
### 测试
	
	更改客户端代码里面的连接IP信息，以下随意选择一个：
	
		192.168.149.149 9050
		
		192.168.149.150 9050
	
	启动多次客户端，查看控制台输出的 服务器IP地址，可以看到连接的服务器有两台


