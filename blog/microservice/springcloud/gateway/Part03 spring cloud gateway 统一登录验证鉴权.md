
# spring cloud gateway 统一登录验证鉴权

### 项目相关说明

    创建的 maven 项目：

        网关 mrh-spring-cloud-gateway                 延用 Part01 创建的网关

        服务 mrh-spring-cloud-api-admin               延用 Part01 创建的服务

        模块 mrh-spring-cloud-reference               存放服务共享定义

    额外引入组件：

        spring cloud bus amqp                         用于网关与服务之间的数据交换，降低网关与其他服务的耦合度

        spring boot redis                             用户登录令牌的存储

        json web token                                用户登录令牌生成工具

### 创建 mrh-spring-cloud-reference

    引入 maven 依赖：

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-bus-amqp</artifactId>
            <optional>true</optional>
        </dependency>

    定义网关 api 类：

        public class GatewayApi implements Serializable {

            private static final long serialVersionUID = 4577510006064437260L;

            private long apiId;                     // 接口ID

            private String apiName;                 // 接口名称

            private String serviceId;               // 接口所属服务

            private HttpMethod apiMethod;           // 接口请求路径

            private String apiPath;                 // 接口请求方法

            private boolean isLogin;                // 是否登录接口

            private boolean isAnonymous;            // 是否允许匿名访问

            private boolean isEnabled;              // 是否允许使用

            // getter and setter

        }

    定义网关角色类：

        public class GatewayRole implements Serializable {

            private static final long serialVersionUID = -8365187605424523995L;

            private long roleId;                        // 角色ID

            private String roleName;                    // 角色名称

            private String description;                 // 角色描述

            private boolean isEnabled;                  // 是否允许使用

            private Duration tokenToLive;               // 令牌生存时长

            private boolean tokenDiscard;               // 令牌废弃验证

            private Set<Long> apiIds;                   // 角色可访问 api 列表

            // getter and setter

        }

    定义网关启动事件：

        public class GatewayStartedEvent extends RemoteApplicationEvent {

            private static final long serialVersionUID = 379500815613468417L;

            @SuppressWarnings("unused")
            private GatewayStartedEvent() {}

            public GatewayStartedEvent(Object source, String originService, Destination destination) {
                super(source, originService, destination);
            }

        }

    定义网关权限信息推送事件：

        public class GatewayAuthorityEvent extends RemoteApplicationEvent {

            private static final long serialVersionUID = 6114742213437288028L;

            private List<GatewayApi> apis;        // 接口信息

            private List<GatewayRole> roles;      // 角色信息

            private long version;                 // 版本号

            @SuppressWarnings("unused")
            private GatewayAuthorityEvent() {}

            public GatewayAuthorityEvent(Object source, String originService, Destination destination,
                    List<GatewayApi> apis, List<GatewayRole> roles, long version) {
                super(source, originService, destination);
                this.apis = apis;
                this.roles = roles;
                this.version = version;
            }

            // getter

        }

    定义网关权限存取接口：

        public interface GatewayAuthorityRepository {

            /**
             * 刷新所有信息
             *
             * @param apis
             * @param roles
             * @param version
             */
            public void refresh(List<GatewayApi> apis, List<GatewayRole> roles, long version);

            /**
             * 获取 api 信息
             *
             * @param method
             * @param path
             * @return
             */
            public GatewayApi match(HttpMethod method, String path);

            /**
             * 获取 role 信息
             *
             * @param roleId
             * @return
             */
            public GatewayRole match(long roleId);

        }

### mrh-spring-cloud-gateway 集成 spring cloud bus

    添加 maven 配置：

        <dependency>
            <groupId>org.lushen.mrh</groupId>
            <artifactId>mrh-spring-cloud-reference</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-bus-amqp</artifactId>
        </dependency>
        <dependency>
            <groupId>org.apache.commons</groupId>
            <artifactId>commons-collections4</artifactId>
        </dependency>

    添加 application.yml 配置：

        spring:
          rabbitmq:
            host: 192.168.140.144
            port: 5672
            username: rabbitmq
            password: 123456
            connection-timeout: 0
            publisher-confirms: true
            publisher-returns: true

    添加启动类注解：

        @RemoteApplicationEventScan(basePackageClasses={GatewayStartedEvent.class, GatewayAuthorityEvent.class})

    创建网关事件发布与监听器：

        @Component
        public class GatewayBusEventPublisherListener implements ApplicationListener<ApplicationEvent> {

            private final Log log = LogFactory.getLog(getClass());

            @Autowired
            private ApplicationContext applicationContext;
            @Autowired
            private BusProperties busProperties;
            @Autowired
            private Destination.Factory destinationFactory;
            @Autowired
            private GatewayAuthorityRepository authorityRepository;

            @Override
            public void onApplicationEvent(ApplicationEvent event) {

                // 网关启动完成，发布网关已启动事件
                if (event instanceof ApplicationReadyEvent) {
                    GatewayStartedEvent gatewayStartedEvent = new GatewayStartedEvent(this, busProperties.getId(), destinationFactory.getDestination(null));
                    applicationContext.publishEvent(gatewayStartedEvent);
                    log.info("Publish event " + gatewayStartedEvent);
                }

                // 监听到网关权限信息事件，更新权限信息
                if(event instanceof GatewayAuthorityEvent) {
                    log.info("Handle event " + event);
                    GatewayAuthorityEvent authorityEvent = (GatewayAuthorityEvent) event;
                    authorityRepository.refresh(authorityEvent.getApis(), authorityEvent.getRoles(), authorityEvent.getVersion());
                }

            }

        }

    添加网关权限信息存取接口实现：

        @Component
        public class GatewayAuthorityRepositoryImpl implements GatewayAuthorityRepository {

            private final Log log = LogFactory.getLog(getClass());

            private final AtomicReference<MultiKeyMap<String, GatewayApi>> apiHolder = new AtomicReference<>(new MultiKeyMap<>());

            private final AtomicReference<Map<Long, GatewayRole>> roleHolder = new AtomicReference<>(new HashMap<>());

            private long version;

            @Override
            public synchronized void refresh(List<GatewayApi> apis, List<GatewayRole> roles, long version) {

                if(this.version >= version) {
                    return;
                }

                log.info(String.format("refresh repository, version number from %s to %s", this.version, version));

                MultiKeyMap<String, GatewayApi> apiCache = new MultiKeyMap<>();
                apis.forEach(api -> apiCache.put(api.getApiMethod().name(), api.getApiPath(), api));

                Map<Long, GatewayRole> roleCache = new HashMap<>();
                roles.forEach(role -> roleCache.put(role.getRoleId(), role));

                this.apiHolder.set(apiCache);
                this.roleHolder.set(roleCache);
                this.version = version;

            }

            @Override
            public GatewayApi match(HttpMethod method, String path) {
                return apiHolder.get().get(method.name(), path);
            }

            @Override
            public GatewayRole match(long roleId) {
                return roleHolder.get().get(roleId);
            }

        }

### mrh-spring-cloud-api-admin 集成 spring cloud bus

    添加 maven 配置：

        <dependency>
            <groupId>org.lushen.mrh</groupId>
            <artifactId>mrh-spring-cloud-reference</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-bus-amqp</artifactId>
        </dependency>

    添加 application.yml 配置：

        spring:
          rabbitmq:
            host: 192.168.140.144
            port: 5672
            username: rabbitmq
            password: 123456
            connection-timeout: 0
            publisher-confirms: true
            publisher-returns: true

    添加启动类注解：

        @RemoteApplicationEventScan(basePackageClasses={GatewayStartedEvent.class, GatewayAuthorityEvent.class})

    创建网关事件发布与监听器：

        @Component
        public class GatewayBusEventPublisherListener extends DefaultPointcutAdvisor implements ApplicationListener<ApplicationEvent>, InitializingBean {

            private final Log log = LogFactory.getLog(getClass());

            @Autowired
            private ApplicationContext applicationContext;
            @Autowired
            private BusProperties busProperties;
            @Autowired
            private Destination.Factory destinationFactory;

            @Override
            public void onApplicationEvent(ApplicationEvent event) {
                if(event instanceof GatewayStartedEvent || event instanceof ApplicationReadyEvent) {
                    publish();
                }
            }

            @Override
            public void afterPropertiesSet() throws Exception {
                this.setAdvice(new AfterReturningAdvice() {
                    @Override
                    public void afterReturning(Object returnValue, Method method, Object[] arg2, Object target) throws Throwable {
                        publish();
                    }
                });
                this.setPointcut(new Pointcut() {
                    @Override
                    public ClassFilter getClassFilter() {
                        return new ClassFilter() {
                            @Override
                            public boolean matches(Class<?> clazz) {
                                return clazz.getPackage().getName().equals(ApiService.class.getPackage().getName());
                            }
                        };
                    }
                    @Override
                    public MethodMatcher getMethodMatcher() {
                        // 根据实际进行调整
                        return new StaticMethodMatcher() {
                            @Override
                            public boolean matches(Method method, Class<?> targetClass) {
                                return method.getName().equals("update");
                            }
                        };
                    }
                });
            }

            private void publish() {

                // 查询权限信息，根据实际进行调整 (不能注入使用，否则切面不生效)
                List<GatewayApi> apis = applicationContext.getBean(ApiService.class).list();
                List<GatewayRole> roles = applicationContext.getBean(RoleService.class).list();
                long version = System.currentTimeMillis();

                // 发布权限信息事件
                GatewayAuthorityEvent authorityEvent = new GatewayAuthorityEvent(this, busProperties.getId(), destinationFactory.getDestination(null), apis, roles, version);
                applicationContext.publishEvent(authorityEvent);
                log.info("publish event " + authorityEvent);

            }

        }

    创建测试 service：

        @Service
        public class ApiService {

            public List<GatewayApi> list() {

                List<GatewayApi> apis = new ArrayList<GatewayApi>();

                GatewayApi api = new GatewayApi();
                api.setAnonymous(true);
                api.setApiId(1);
                api.setApiMethod(HttpMethod.GET);
                api.setApiPath("/admin/api/welcome");
                api.setApiName("测试");
                api.setEnabled(true);
                api.setLogin(false);
                api.setServiceId("mrh-spring-cloud-api-admin");
                apis.add(api);

                GatewayApi api2 = new GatewayApi();
                api2.setAnonymous(false);
                api2.setApiId(2);
                api2.setApiMethod(HttpMethod.GET);
                api2.setApiPath("/admin/api/auth/apis/list");
                api2.setApiName("测试");
                api2.setEnabled(true);
                api2.setLogin(false);
                api2.setServiceId("mrh-spring-cloud-api-admin");
                apis.add(api2);

                return apis;
            }

            public void update() {

            }

        }

        @Service
        public class RoleService {

            public List<GatewayRole> list() {

                List<GatewayRole> roles = new ArrayList<GatewayRole>();

                GatewayRole role = new GatewayRole();
                role.setRoleId(1);
                role.setDescription("角色描述");
                role.setEnabled(true);
                role.setRoleName("测试角色");
                role.setTokenDiscard(true);
                role.setTokenToLive(Duration.ofHours(2));
                role.setApiIds(new HashSet<Long>(Arrays.asList(1L, 2L)));

                roles.add(role);

                return roles;
            }

            public void update() {

            }

        }

    创建测试接口：

        @RestController
        @RequestMapping(path="api/auth")
        public class AuthorityController {

            @Autowired
            private ApiService apiService;
            @Autowired
            private RoleService roleService;

            @GetMapping(path="apis/list")
            public List<GatewayApi> listApis() {
                return apiService.list();
            }

            @GetMapping(path="roles/list")
            public List<GatewayRole> listRoles() {
                return roleService.list();
            }

            @GetMapping(path="api/update")
            public String updateApi() {
                apiService.update();
                return "success";
            }

            @GetMapping(path="role/update")
            public String updateRole() {
                roleService.update();
                return "success";
            }

        }

### mrh-spring-cloud-gateway 使用 spring cloud bus

    分别进行以下操作：

        先启动 mrh-spring-cloud-gateway，再启动 mrh-spring-cloud-api-admin

        先启动 mrh-spring-cloud-api-admin，再启动 mrh-spring-cloud-api-admin

        两者都处于启动状态，重启 mrh-spring-cloud-gateway

        两者都处于启动状态，重启 mrh-spring-cloud-api-admin

    网关都能正常获取到权限信息

### mrh-spring-cloud-gateway 统一接口验证



### mrh-spring-cloud-gateway 统一生成登录令牌




### mrh-spring-cloud-gateway 统一登录验证


### mrh-spring-cloud-gateway 统一权限验证
