
# spring cloud 自定义指标 prometheus

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://prometheus.io/docs/introduction/overview/

        https://prometheus.io/docs/concepts/metric_types/

        https://github.com/prometheus/client_java

        https://micrometer.io/docs

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### micrometer 指标类型

  * 主要有以下几种类型

        Counter         # 只增不减的指标类型数据，例如调用次数，消息总数

        Gauge           # 可增可见的指标类型数据，例如服务器磁盘剩余空间

        Histogram       # 直方图指标类型数据，用于统计和分析样本的分布情况

        Summary         # 摘要指标类型数据，与 Histogram 类似

### 自定义 Counter 指标

  * 统计 /api/** 接口的总调用次数，使用拦截器实现：

        @Component
        public class PrometheusInterceptor implements HandlerInterceptor, WebMvcConfigurer, InitializingBean {

            @Autowired
            private MeterRegistry registry;

            private Counter counter;

            @Override
            public void afterPropertiesSet() throws Exception {
                this.counter = this.registry.counter("http_api_requests_second_count");
            }

            @Override
            public void addInterceptors(InterceptorRegistry registry) {
                registry.addInterceptor(this).addPathPatterns("/api/**");
            }

            @Override
            public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
                this.counter.increment();
                return true;
            }

        }

### 自定义 Gauge 指标

  * 统计 /api/** 接口的瞬时并发量，使用拦截器实现：

        @Component
        public class PrometheusGaugeInterceptor implements HandlerInterceptor, WebMvcConfigurer, InitializingBean {

            @Autowired
            private MeterRegistry registry;

            private AtomicLong value;

            @Override
            public void afterPropertiesSet() throws Exception {
                this.value = this.registry.gauge("http_api_requests_current_queries_count", new AtomicLong());
            }

            @Override
            public void addInterceptors(InterceptorRegistry registry) {
                registry.addInterceptor(this).addPathPatterns("/api/**");
            }

            @Override
            public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
                value.incrementAndGet();
                return true;
            }

            @Override
            public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
                value.decrementAndGet();
            }

        }

### 自定义 Histogram 指标

  * 统计 /api/** 请求body的大小及其总次数：

        @Component
        public class PrometheusHistogramInterceptor implements HandlerInterceptor, WebMvcConfigurer, InitializingBean {

        	@Autowired
        	private PrometheusMeterRegistry registry;

        	private DistributionSummary summary;

        	@Override
        	public void afterPropertiesSet() throws Exception {
        		summary = registry.summary("http_api_requests_bytes");
        	}

        	@Override
        	public void addInterceptors(InterceptorRegistry registry) {
        		registry.addInterceptor(this).addPathPatterns("/api/**");
        	}

        	@Override
        	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        		summary.record(Optional.ofNullable(request.getContentLength()).filter(e -> e>0).orElse(0));
        		return true;
        	}

        }
