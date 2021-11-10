
# canal

#### 创建 maven 项目

    依赖配置：

        <dependency>
          <groupId>com.alibaba.otter</groupId>
          <artifactId>canal.client</artifactId>
          <version>1.1.5</version>
        </dependency>

#### 客户端消费接口

    /**
    * canal 消息订阅接口
    *
    * @author hlm
    */
    public interface CanalSubscriber {

    /**
     * canal 消息处理
     *
     * @param message
     * @throws Exception
     */
    public void subscribe(Message message) throws Exception;

    }

#### 客户端连接信息

    /**
     * canal properties
     *
     * @author hlm
     */
    public class CanalProperties {

    	protected String zkServers;            // canal zookeeper连接地址

    	protected List<Address> addresses;     // canal 集群连接地址

    	protected String host = "localhost";   // canal host

    	protected int port = 11111;            // canal port

    	protected String destination;          // canal instance

    	protected String username;             // canal username

    	protected String password;             // canal password

    	protected String subscribe;            // canal subscribe

    	protected int batchSize = 1;           // canal batchSize

    	public String getZkServers() {
    		return zkServers;
    	}

    	public void setZkServers(String zkServers) {
    		this.zkServers = zkServers;
    	}

    	public List<Address> getAddresses() {
    		return addresses;
    	}

    	public void setAddresses(List<Address> addresses) {
    		this.addresses = addresses;
    	}

    	public String getHost() {
    		return host;
    	}

    	public void setHost(String host) {
    		this.host = host;
    	}

    	public int getPort() {
    		return port;
    	}

    	public void setPort(int port) {
    		this.port = port;
    	}

    	public String getDestination() {
    		return destination;
    	}

    	public void setDestination(String destination) {
    		this.destination = destination;
    	}

    	public String getUsername() {
    		return username;
    	}

    	public void setUsername(String username) {
    		this.username = username;
    	}

    	public String getPassword() {
    		return password;
    	}

    	public void setPassword(String password) {
    		this.password = password;
    	}

    	public String getSubscribe() {
    		return subscribe;
    	}

    	public void setSubscribe(String subscribe) {
    		this.subscribe = subscribe;
    	}

    	public int getBatchSize() {
    		return batchSize;
    	}

    	public void setBatchSize(int batchSize) {
    		this.batchSize = batchSize;
    	}

    	@Override
    	public String toString() {
    		StringBuilder builder = new StringBuilder();
    		builder.append("[zkServers=");
    		builder.append(zkServers);
    		builder.append(", addresses=");
    		builder.append(addresses);
    		builder.append(", host=");
    		builder.append(host);
    		builder.append(", port=");
    		builder.append(port);
    		builder.append(", destination=");
    		builder.append(destination);
    		builder.append(", username=");
    		builder.append(username);
    		builder.append(", password=");
    		builder.append(password);
    		builder.append(", subscribe=");
    		builder.append(subscribe);
    		builder.append(", batchSize=");
    		builder.append(batchSize);
    		builder.append("]");
    		return builder.toString();
    	}

    	public class Address {

    		private String host;

    		private int port;

    		public String getHost() {
    			return host;
    		}

    		public void setHost(String host) {
    			this.host = host;
    		}

    		public int getPort() {
    			return port;
    		}

    		public void setPort(int port) {
    			this.port = port;
    		}

    		@Override
    		public String toString() {
    			StringBuilder builder = new StringBuilder();
    			builder.append("(host=");
    			builder.append(host);
    			builder.append(", port=");
    			builder.append(port);
    			builder.append(")");
    			return builder.toString();
    		}

    	}

    }

#### 重试客户端

    /**
     * canal 重试客户端
     *
     * @author hlm
     */
    public class CanalRetryConnector extends CanalProperties implements InitializingBean, DisposableBean {

    	private final Log log = LogFactory.getLog(getClass().getSimpleName());

    	// 线程池
    	private final ExecutorService executor = Executors.newSingleThreadExecutor();

    	// 连接重试次数
    	private final AtomicLong retries = new AtomicLong(0);

    	// 是否运行中
    	private boolean isRunning = true;

    	// canal 连接对象
    	private CanalConnector connector;

    	// canal 消费对象
    	private List<CanalSubscriber> subscribers;

    	public CanalRetryConnector(CanalSubscriber subscriber) {
    		this(Arrays.asList(subscriber));
    	}

    	public CanalRetryConnector(List<CanalSubscriber> subscribers) {
    		super();
    		this.subscribers = subscribers;
    	}

    	@Override
    	public void afterPropertiesSet() throws Exception {

    		// 创建连接对象
    		if(zkServers != null) {
    			this.connector = CanalConnectors.newClusterConnector(zkServers, destination, username, password);
    		}
    		if(addresses != null) {
    			List<InetSocketAddress> socketAddresses = addresses.stream().map(e -> new InetSocketAddress(e.getHost(), e.getPort())).collect(Collectors.toList());
    			this.connector = CanalConnectors.newClusterConnector(socketAddresses, destination, username, password);
    		}
    		if(this.connector == null) {
    			this.connector = CanalConnectors.newSingleConnector(new InetSocketAddress(host, port), destination, username, password);
    		}

    		// 开始执行订阅
    		this.executor.execute(() -> doRun());

    	}

    	private void doRun() {

    		try {

    			// 重试先断开连接
    			if(retries.getAndIncrement() > 0) {
    				connector.disconnect();
    				Thread.sleep(retries.get()>20? 5000L:100L);
    			}

    			// 初始化连接
    			connector.connect();
    			if(subscribe != null) {
    				connector.subscribe(subscribe);
    			} else {
    				connector.subscribe();
    			}
    			connector.rollback();

    			while(isRunning) {

    				// 拉取数据
    				Message message = connector.getWithoutAck(batchSize);

    				// 无数据休眠
    				if(message.getId() == -1) {
    					Thread.sleep(50L);
    					continue;
    				}

    				// 消费数据
    				try {
    					for(CanalSubscriber subscriber : subscribers) {
    						subscriber.subscribe(message);
    					}
    					connector.ack(message.getId());
    				} catch (Exception e) {
    					connector.rollback(message.getId());
    				}

    			}

    		} catch (Exception ex) {

    			// 非退出异常，重新执行订阅
    			if(isRunning) {
    				log.warn("Retry to execute method doRun(), cause by: " + ex.getMessage(), ex);
    				executor.execute(() -> doRun());
    			} else {
    				log.warn("Canal has been stopped and will not retry to execute method doRun()");
    			}

    		}

    	}

    	@Override
    	public void destroy() throws Exception {

    		try {

    			// 关闭线程池
    			if( ! executor.isTerminated() ) {
    				isRunning = false;
    				executor.shutdownNow();
    			}

    		} finally {

    			// 关闭连接
    			connector.disconnect();

    		}

    	}

    }

#### 客户端消费实现

    /**
    * 测试客户端
    *
    * @author hlm
    */
    public class CanalPrintSubscriber implements CanalSubscriber {

        @Override
        public void subscribe(Message message) throws Exception {

            for(CanalEntry.Entry entry : message.getEntries()) {

                if (entry.getEntryType() == CanalEntry.EntryType.TRANSACTIONBEGIN
                        || entry.getEntryType() == CanalEntry.EntryType.TRANSACTIONEND) {
                    continue;
                }

                CanalEntry.RowChange rowChage = CanalEntry.RowChange.parseFrom(entry.getStoreValue());
                CanalEntry.EventType eventType = rowChage.getEventType();

                System.out.println("--------------------------------------------------");
                System.out.println("logfileName : " + entry.getHeader().getLogfileName());
                System.out.println("logfileOffset : " + entry.getHeader().getLogfileOffset());
                System.out.println("schemaName : " + entry.getHeader().getSchemaName());
                System.out.println("tableName : " + entry.getHeader().getTableName());
                System.out.println("eventType : " + eventType);

                for (CanalEntry.RowData rowData : rowChage.getRowDatasList()) {
                    System.out.println("-------------------before-----------------------");
                    for (CanalEntry.Column column : rowData.getBeforeColumnsList()) {
                        System.out.println(column.getName() + " : " + column.getValue() + ", update=" + column.getUpdated());
                    }
                    System.out.println("-------------------after-----------------------");
                    for (CanalEntry.Column column : rowData.getAfterColumnsList()) {
                        System.out.println(column.getName() + " : " + column.getValue() + ", update=" + column.getUpdated());
                    }
                }

            }

        }

    }

#### 订阅测试

    public class TestCanal {

        public static void main(String[] args) throws Exception {

            CanalSubscriber subscriber = new CanalPrintSubscriber();

            CanalRetryConnector connector = new CanalRetryConnector(subscriber);
            connector.setHost("192.168.140.210");
            connector.setPort(11111);
            connector.setDestination("example");
            connector.setSubscribe(".*\\..*");
            connector.setBatchSize(1);
            connector.afterPropertiesSet();

        }

    }
