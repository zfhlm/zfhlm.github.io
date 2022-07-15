
# spring cloud discovery 自定义负载均衡策略

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-commons/docs/current/reference/html/#simplediscoveryclient

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 源码分析

  * 查看 openfeign 负载均衡客户端配置：

        // org.springframework.cloud.openfeign.loadbalancer.FeignBlockingLoadBalancerClient

        // org.springframework.cloud.client.loadbalancer.LoadBalancerClient

        // org.springframework.cloud.loadbalancer.blocking.client.BlockingLoadBalancerClient

        @Override
        public <T> ServiceInstance choose(String serviceId, Request<T> request) {
            ReactiveLoadBalancer<ServiceInstance> loadBalancer = loadBalancerClientFactory.getInstance(serviceId);
            if (loadBalancer == null) {
                return null;
            }
            Response<ServiceInstance> loadBalancerResponse = Mono.from(loadBalancer.choose(request)).block();
            if (loadBalancerResponse == null) {
                return null;
            }
            return loadBalancerResponse.getServer();
        }

  * 可以看到，负载均衡策略实现，最终交给 ReactiveLoadBalancer 实现，官方提供了两个实现类：

        // org.springframework.cloud.client.loadbalancer.reactive.ReactiveLoadBalancer<ServiceInstance>

        // org.springframework.cloud.loadbalancer.core.ReactorServiceInstanceLoadBalancer

        // 随机策略 org.springframework.cloud.loadbalancer.core.RandomLoadBalancer

        // 轮询策略 org.springframework.cloud.loadbalancer.core.RoundRobinLoadBalancer

  * 搜索两个实现类，随机策略未配置，默认使用轮询策略：

        // org.springframework.cloud.loadbalancer.annotation.LoadBalancerClientConfiguration

        @Bean
        @ConditionalOnMissingBean
        public ReactorLoadBalancer<ServiceInstance> reactorServiceInstanceLoadBalancer(Environment environment,
                LoadBalancerClientFactory loadBalancerClientFactory) {
            String name = environment.getProperty(LoadBalancerClientFactory.PROPERTY_NAME);
            return new RoundRobinLoadBalancer(
                    loadBalancerClientFactory.getLazyProvider(name, ServiceInstanceListSupplier.class), name);
        }

### 自定义负载均衡策略

  * 参考 RandomLoadBalancer 和 RoundRobinLoadBalancer ，重写节点选择逻辑，例如权重轮询：

        // 假设节点及其权重  A=2  B=1  C=4  D=2  权重轮询顺序： A-B-C-D-A-C-D-C-C  A-B-C-D-A-C-D-C-C

        // 轮询比值从 1 开始，每次轮询比值加 1，若当次轮询比值大于权重，则跳过该节点，直到所有节点轮询完毕，从新开始下一轮

        public class WeightRoundRobinLoadBalancer implements ReactorServiceInstanceLoadBalancer {

            private static final Log log = LogFactory.getLog(WeightRoundRobinLoadBalancer.class);

            private final String serviceId;

            private ObjectProvider<ServiceInstanceListSupplier> serviceInstanceListSupplierProvider;

            private final AtomicInteger currWeight = new AtomicInteger(1);

            private final AtomicInteger offset = new AtomicInteger(0);

            public WeightRoundRobinLoadBalancer(ObjectProvider<ServiceInstanceListSupplier> serviceInstanceListSupplierProvider, String serviceId) {
                this.serviceId = serviceId;
                this.serviceInstanceListSupplierProvider = serviceInstanceListSupplierProvider;
            }

            @SuppressWarnings("rawtypes")
            @Override
            public Mono<Response<ServiceInstance>> choose(Request request) {
                ServiceInstanceListSupplier supplier = serviceInstanceListSupplierProvider
                        .getIfAvailable(NoopServiceInstanceListSupplier::new);
                return supplier.get(request).next().map(serviceInstances -> processInstanceResponse(supplier, serviceInstances));
            }

            private Response<ServiceInstance> processInstanceResponse(ServiceInstanceListSupplier supplier, List<ServiceInstance> serviceInstances) {
                Response<ServiceInstance> serviceInstanceResponse = getInstanceResponse(serviceInstances);
                if (supplier instanceof SelectedInstanceCallback && serviceInstanceResponse.hasServer()) {
                    ((SelectedInstanceCallback) supplier).selectedServiceInstance(serviceInstanceResponse.getServer());
                }
                return serviceInstanceResponse;
            }

            private Response<ServiceInstance> getInstanceResponse(List<ServiceInstance> instances) {

                if (instances.isEmpty()) {
                    if (log.isWarnEnabled()) {
                        log.warn("No servers available for service: " + serviceId);
                    }
                    return new EmptyResponse();
                }

                // 只有一个节点，直接返回
                if(instances.size() == 1) {
                    return new DefaultResponse(instances.get(0));
                }

                // 排序
                List<ServiceInstance> sortedInstances = new ArrayList<ServiceInstance>(instances);
                Collections.sort(sortedInstances, Comparator.comparing(ServiceInstance::getInstanceId));

                synchronized (this) {

                    while(true) {

                        // 根据偏移量，获取筛选节点列表
                        List<ServiceInstance> subInstances = sortedInstances.subList(offset.get(), sortedInstances.size());

                        for(ServiceInstance instance : subInstances) {

                            // 偏移量+1，超出则重置
                            if(offset.incrementAndGet() == sortedInstances.size()) {
                                offset.set(0);
                            }

                            // 大于等于权重比值，返回该节点
                            if(getWeight(instance) >= currWeight.get()) {
                                return new DefaultResponse(instance);
                            }

                            // 如果筛选列表为全量，重置权重比值，继续下一次筛选；否则权重比值+1，继续下一次筛选
                            if(subInstances.size() == sortedInstances.size()) {
                                currWeight.set(1);
                            } else {
                                currWeight.incrementAndGet();
                            }

                        }

                    }

                }

            }

            private int getWeight(ServiceInstance instance) {
                try {
                    return Optional.ofNullable(instance.getMetadata()).map(e -> e.get("weight")).map(Integer::parseInt).filter(e -> e>0).orElse(1);
                } catch (Exception e2) {
                    return 1;
                }
            }

        }
