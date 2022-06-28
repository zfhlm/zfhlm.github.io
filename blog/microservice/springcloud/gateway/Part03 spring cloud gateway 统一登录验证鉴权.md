
# spring cloud gateway 用户验证与鉴权

### 技术选型参考

    spring cloud gateway 基本组件

    spring cloud bus amqp 用于网关数据交换，降低网关与其他服务的耦合度

    spring cloud zookeeper 服务注册与发现

    spring boot redis 登录令牌合法性验证

    jwt 登录令牌生成

### 网关鉴权信息交换

    gateway 鉴权相关信息定义参考：

        // 接口信息
        public class GatewayApi implements Serializable {

            private String apiId;                   // 接口ID

            private String apiName;                 // 接口名称

            private String serviceId;               // 接口所属服务ID

            private String apiMethod;               // 接口请求路径

            private String apiPath;                 // 接口请求方法

            private boolean isLogin;                // 是否登录接口

            private boolean isAnonymous;            // 是否允许匿名访问

            private boolean isInfoBody;             // 是否 info 请求响应 body

            private boolean isEnabled;              // 是否允许访问

            // getter and setter

        }

        // 角色及其权限信息
        public class GatewayRole implements Serializable {

          private String id;                          // 角色ID

          private String name;                        // 角色名称

          private String description;                 // 角色描述

          private Boolean isEnabled;                  // 是否允许使用

          private Duration tokenToLive;               // 令牌生存时长

          private Set<String> apiIds;                 // 角色可访问 api ID 列表

          // getter and setter

        }

    bus 鉴权相关事件定义参考，定义两个 bus event 对象：

        // 网关启动事件
        public class GatewayStartedEvent extends RemoteApplicationEvent {

            @SuppressWarnings("unused")
            private GatewayStartedEvent() {}

            public GatewayStartedEvent(Object source, String originService, String destinationService) {
                super(source, originService, destinationService);
            }

        }

        // 网关权限相关信息推送事件
        public class GatewayAuthMessageEvent extends RemoteApplicationEvent {

            private List<GatewayApi> apis;

            private List<GatewayRole> roles;

            private long version;

            @SuppressWarnings("unused")
            private GatewayAuthMessageEvent() {}

            public AccessApiChangedEvent(Object source, String originService, String destinationService ,
                    List<GatewayApi> apis, List<GatewayRole> roles, long version) {
                super(source, originService, destinationService);
                this.apis = apis;
                this.roles = roles;
                this.version = version;
            }

            // getter

        }

    gateway、service、bus 的交互流程，数据交换都是异步，耦合度降到最低：

        gateway 在应用启动后，发布 GatewayStartedEvent 到 bus amqp

        service 在应用启动后、接收到 GatewayStartedEvent 后、权限信息变更后，发布 GatewayAuthMessageEvent 到 bus amqp

        gateway 从 bus amqp 接收到 GatewayAuthMessageEvent，根据版本号决定是否更新本地的权限相关信息

### 统一登录与验证





### 自定义过滤器
