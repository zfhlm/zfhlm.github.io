
# spring cloud gateway 链路追踪 sleuth

### 项目源码地址

    https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 官方文档地址

    https://docs.spring.io/spring-cloud-sleuth/docs/current/reference/htmlsingle/spring-cloud-sleuth.html

### 网关配置

    因为网关使用的 reactor 模型，日志不输出当前请求用户的相关信息，交给下级服务去处理

    添加 maven 依赖：

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-sleuth</artifactId>
        </dependency>

    添加 application.yml 配置：

        # 这里采用 DECORATE_ON_EACH 模式，其他模式耦合度高，或者有追踪丢失问题
        spring:
          sleuth:
            reactor:
              instrumentation-type: DECORATE_ON_EACH

    更改 log4j2 日志输出格式：

        %d{yyyy-MM-dd HH:mm:ss.SSS} %-5level %logger{36} [%equals{%X{traceId}}{}{N/A},%equals{%X{spanId}}{}{N/A}] - %msg%n

    输出日志内容示例：

        2022-07-03 07:30:18.829 INFO  PrintRequestLineFilter [ff61dda5defcd56d,ff61dda5defcd56d] - HTTP POST /admin/api/permission/login
        2022-07-03 07:30:18.830 INFO  PrintRequestJsonBodyFilter [ff61dda5defcd56d,ff61dda5defcd56d] - HTTP request body : {
            "ID": -56142218,
            "name": "quis velit eiusmod"
        }
        2022-07-03 07:30:20.567 INFO  AuthenticateFilter [ff61dda5defcd56d,e3e3711ba243e017] - HTTP login user 1 role 1
        2022-07-03 07:30:20.670 INFO  PrintResponseJsonBodyFilter [ff61dda5defcd56d,ff61dda5defcd56d] - HTTP response body : {"errcode":0,"errmsg":"success","data":{"token":"xxx"}}


### 服务配置

    添加 maven 依赖：

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-sleuth</artifactId>
        </dependency>

    更改 log4j2 日志输出格式：

        %d{yyyy-MM-dd HH:mm:ss.SSS} %-5level %logger{36} [%equals{%X{traceId}}{}{N/A},%equals{%X{spanId}}{}{N/A}] - %msg%n

    输出日志内容示例：

        2022-07-03 07:29:46.084 INFO  org.lushen.mrh.cloud.api.admin.config.GatewayBusEventPublisherListener [,] - publish event [GatewayPermissionEvent@571db8b4 id = 'c7ef0552-ec01-458e-86db-ba663be94f51', originService = 'mrh-spring-cloud-api-admin:8888:78eea26ec9159c8fbc0699ce9d31c8fe', destinationService = '**']
        2022-07-03 07:29:46.214 INFO  org.springframework.cloud.stream.binder.DefaultBinderFactory [62ebec624a43258e,8d4a1faaeac5a042] - Retrieving cached binder: rabbit
        2022-07-03 07:30:20.438 INFO  org.apache.catalina.core.ContainerBase.[Tomcat].[localhost].[/] [ff61dda5defcd56d,1bc4f5256ca15946] - Initializing Spring DispatcherServlet 'dispatcherServlet'
        2022-07-03 07:30:20.439 INFO  org.springframework.web.servlet.DispatcherServlet [ff61dda5defcd56d,1bc4f5256ca15946] - Initializing Servlet 'dispatcherServlet'
        2022-07-03 07:30:20.440 INFO  org.springframework.web.servlet.DispatcherServlet [ff61dda5defcd56d,1bc4f5256ca15946] - Completed initialization in 1 ms

### 服务扩展 log4j2

    注意，当前扩展方法在 reactor 模型中无法使用

    创建 log4j2 plugin 实现，从请求上下文中获取请求对象，再根据请求对象获取网关传输过来的用户信息：

        @Plugin(name = "Log4j2UserPatternConverter", category = PatternConverter.CATEGORY)
        @ConverterKeys({"user", "USER"})
        @PerformanceSensitive("allocation")
        public class Log4j2UserPatternConverter extends LogEventPatternConverter {

            private Log4j2UserPatternConverter() {
                super("User", "user");
            }
            public static Log4j2UserPatternConverter newInstance(final String[] options) {
                return new Log4j2UserPatternConverter();
            }

            @Override
            public void format(LogEvent event, StringBuilder toAppendTo) {

                // 当前请求上下文
                RequestAttributes attributes = RequestContextHolder.getRequestAttributes();

                // 获取请求头
                Function<String, String> getHeaderValue = (name -> {
                    if(attributes instanceof ServletRequestAttributes) {
                        return ((ServletRequestAttributes)attributes).getRequest().getHeader(name);
                    } else if(attributes instanceof WebRequest) {
                        return ((WebRequest)attributes).getHeader(name);
                    } else {
                        return null;
                    }
                });
                String id = getHeaderValue.apply(JWT_DELIVER_ID_HEADER);
                String roleId = getHeaderValue.apply(JWT_DELIVER_ROLE_ID_HEADER);

                // 追加到日志输出
                if(id != null && roleId != null) {
                    toAppendTo.append(id).append("-").append(roleId);
                }

            }

        }

    更改 log4j2 的配置信息：

        <!-- 配置扫描插件包 -->
        <Configuration status="info" packages="org.lushen.mrh.cloud.reference.supports.log4j2">

        <!-- 日志输出格式中，添加 %user 追加用户信息 -->
        %d{yyyy-MM-dd HH:mm:ss.SSS} %-5level %logger{36} [%equals{%X{traceId}}{}{N/A},%equals{%X{spanId}}{}{N/A},%equals{%user}{}{N/A}] - %msg%n

    启动后发起请求，日志输出示例，可以看到 1-2 即用户 ID 为 1 角色 ID 为 2：

        2022-07-03 08:10:37.975 INFO  org.lushen.mrh.cloud.api.admin.web.WelcomeController [d15f7c729ffa9977,da0a963c6b8939b9,1-2] - welcome
        2022-07-03 08:10:39.296 INFO  org.lushen.mrh.cloud.api.admin.web.WelcomeController [a82edd531f0f4cc0,168122f334d9085c,1-2] - welcome
        2022-07-03 08:10:40.418 INFO  org.lushen.mrh.cloud.api.admin.web.WelcomeController [83dab9aaaf2201c4,a09a53223487a3de,1-2] - welcome
        2022-07-03 08:10:41.374 INFO  org.lushen.mrh.cloud.api.admin.web.WelcomeController [7daac0d796156e2c,fdcdd8926e47eaa8,1-2] - welcome
