
# spring cloud gateway 链路追踪 sleuth

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-sleuth/docs/current/reference/htmlsingle/spring-cloud-sleuth.html

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 网关 sleuth 装配类型

  * 总共有四种类型：

        DECORATE_QUEUES         # 根据 reactor 运算符队列进行包装，有日志 traceId 丢失问题，对性能影响很大

        DECORATE_ON_EACH        # 对 reactor 所有运算符进行包装，对性能影响很大

        DECORATE_ON_LAST        # 对 reactor 最后一个运算符进行包装，有日志 traceId 丢失问题，对性能影响较大

        MANUAL                  # 使用指定的方式手动控制日志打印，性能影响最小

        (一般选择 DECORATE_ON_EACH 或者 MANUAL，网关日志埋点处相对较少，选择 MANUAL 类型更合适)

### 网关 sleuth 配置 (DECORATE_ON_EACH)

  * 添加 maven 依赖：

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-sleuth</artifactId>
        </dependency>

  * 添加 application.yml 配置：

        spring:
          sleuth:
            reactor:
              instrumentation-type: DECORATE_ON_EACH

  * 更改 log4j2 日志输出格式：

        %d{yyyy-MM-dd HH:mm:ss.SSS} %-5level %logger{36} [%equals{%X{traceId}}{}{N/A},%equals{%X{spanId}}{}{N/A}] - %msg%n

  * 启动网关即可看到日志输出，以下为截取片段：

          2022-07-03 07:30:20.567 INFO  AuthenticateFilter [ff61dda5defcd56d,e3e3711ba243e017] - HTTP login user 1 role 1
          2022-07-03 07:30:20.670 INFO  PrintResponseJsonBodyFilter [ff61dda5defcd56d,ff61dda5defcd56d] - HTTP response body : {"errcode":0,"errmsg":"success","data":{"token":"xxx"}}

### 网关 sleuth 配置 (MANUAL)

  * 更改 application.yml 配置：

        spring:
          sleuth:
            reactor:
              instrumentation-type: MANUAL

  * 自定义日志 Logger 接口：

        public interface GatewayLogger {

            public boolean isFatalEnabled();

            public boolean isErrorEnabled();

            public boolean isWarnEnabled();

            public boolean isInfoEnabled();

            public boolean isDebugEnabled();

            public boolean isTraceEnabled();

            public void fatal(ServerWebExchange exchange, Object message);

            public void fatal(ServerWebExchange exchange, Object message, Throwable t);

            public void error(ServerWebExchange exchange, Object message);

            public void error(ServerWebExchange exchange, Object message, Throwable t);

            public void warn(ServerWebExchange exchange, Object message);

            public void warn(ServerWebExchange exchange, Object message, Throwable t);

            public void info(ServerWebExchange exchange, Object message);

            public void info(ServerWebExchange exchange, Object message, Throwable t);

            public void debug(ServerWebExchange exchange, Object message);

            public void debug(ServerWebExchange exchange, Object message, Throwable t);

            public void trace(ServerWebExchange exchange, Object message);

            public void trace(ServerWebExchange exchange, Object message, Throwable t);

        }

  * 自定义日志 Logger 接口包装类：

        public static class GatewayLoggerDecorator implements GatewayLogger {

            private final Log delegate;

            private final BiConsumer<ServerWebExchange, Runnable> executor;

            public GatewayLoggerDecorator(Log delegate, BiConsumer<ServerWebExchange, Runnable> executor) {
                super();
                this.delegate = delegate;
                this.executor = executor;
            }

            @Override
            public void fatal(ServerWebExchange exchange, Object message) {
                this.executor.accept(exchange, () -> this.delegate.fatal(message));
            }

            @Override
            public void fatal(ServerWebExchange exchange, Object message, Throwable t) {
                this.executor.accept(exchange, () -> this.delegate.fatal(message, t));
            }

            @Override
            public void error(ServerWebExchange exchange, Object message) {
                this.executor.accept(exchange, () -> this.delegate.error(message));
            }

            @Override
            public void error(ServerWebExchange exchange, Object message, Throwable t) {
                this.executor.accept(exchange, () -> this.delegate.error(message, t));
            }

            @Override
            public void warn(ServerWebExchange exchange, Object message) {
                this.executor.accept(exchange, () -> this.delegate.warn(message));
            }

            @Override
            public void warn(ServerWebExchange exchange, Object message, Throwable t) {
                this.executor.accept(exchange, () -> this.delegate.warn(message, t));
            }

            @Override
            public void info(ServerWebExchange exchange, Object message) {
                this.executor.accept(exchange, () -> this.delegate.info(message));
            }

            @Override
            public void info(ServerWebExchange exchange, Object message, Throwable t) {
                this.executor.accept(exchange, () -> this.delegate.info(message, t));
            }

            @Override
            public void debug(ServerWebExchange exchange, Object message) {
                this.executor.accept(exchange, () -> this.delegate.debug(message));
            }

            @Override
            public void debug(ServerWebExchange exchange, Object message, Throwable t) {
                this.executor.accept(exchange, () -> this.delegate.debug(message, t));
            }

            @Override
            public void trace(ServerWebExchange exchange, Object message) {
                this.executor.accept(exchange, () -> this.delegate.trace(message));
            }

            @Override
            public void trace(ServerWebExchange exchange, Object message, Throwable t) {
                this.executor.accept(exchange, () -> this.delegate.trace(message, t));
            }

            @Override
            public boolean isFatalEnabled() {
                return this.delegate.isFatalEnabled();
            }

            @Override
            public boolean isErrorEnabled() {
                return this.delegate.isErrorEnabled();
            }

            @Override
            public boolean isWarnEnabled() {
                return this.delegate.isWarnEnabled();
            }

            @Override
            public boolean isInfoEnabled() {
                return this.delegate.isInfoEnabled();
            }

            @Override
            public boolean isDebugEnabled() {
                return this.delegate.isDebugEnabled();
            }

            @Override
            public boolean isTraceEnabled() {
                return this.delegate.isTraceEnabled();
            }

        }

  * 自定义 sleuth bean holder 用于静态方法方式访问：

        public static class Sleuth {

            private static final AtomicReference<Tracer> TRACER_HOLDER = new AtomicReference<Tracer>();

            private static final AtomicReference<CurrentTraceContext> CURRENT_TRACE_CONTEXT_HOLDER = new AtomicReference<CurrentTraceContext>();

            public static final void initialize(ApplicationContext applicationContext) {
                TRACER_HOLDER.set(applicationContext.getBean(Tracer.class));
                CURRENT_TRACE_CONTEXT_HOLDER.set(applicationContext.getBean(CurrentTraceContext.class));
            }

            public static final Tracer tracer() {
                return TRACER_HOLDER.get();
            }

            public static final CurrentTraceContext currentTraceContext() {
                return CURRENT_TRACE_CONTEXT_HOLDER.get();
            }

        }

  * 自定义日志 Logger 工厂

        public abstract class GatewayLoggerFactory {

            public static GatewayLogger getLog(Class<?> clazz) {
                return getLog(clazz.getName());
            }

            public static GatewayLogger getLog(String name) {
                return new GatewayLogger.GatewayLoggerDecorator(LogFactory.getLog(name), (exchange, runnable) -> {
                    Tracer tracer = GatewayExchangeUtils.Sleuth.tracer();
                    CurrentTraceContext currentTraceContext = GatewayExchangeUtils.Sleuth.currentTraceContext();
                    if(tracer != null && currentTraceContext != null) {
                        WebFluxSleuthOperators.withSpanInScope(tracer, currentTraceContext, exchange, runnable);
                    } else {
                        runnable.run();
                    }
                });
            }

        }

  * 容器启动时对 sleuth bean holder 进行配置：

        @Bean
        public ApplicationContextAware sleuthTracerInitializer() {
            return context -> GatewayExchangeUtils.Sleuth.initialize(context);
        }

  * 在自定义过滤器、异常处理器、断路异常fallback 等处，将 Log 替换为 自定义 Logger 即可：

        // 创建 Logger 对象
        private final GatewayLogger log = GatewayLoggerFactory.getLog(getClass());

        // 使用 Logger 输出日志
        log.info(exchange, "message text");
