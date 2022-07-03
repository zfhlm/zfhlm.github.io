
# spring cloud gateway 登录验证鉴权

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-bus/docs/current/reference/html/

        https://jwt.io/introduction/

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 简单说明(其他查看源码)

  * 项目模块：

        网关 mrh-spring-cloud-gateway                       # 延用 Part01 创建的网关

        服务 mrh-spring-cloud-api-admin                     # 延用 Part01 创建的服务

        模块 mrh-spring-cloud-reference                     # 存放服务共享定义

  * 引入组件：

        spring cloud bus amqp                               # 用于网关与服务之间的数据交换，降低网关与其他服务的耦合度

        json web token                                      # 用户登录令牌生成工具

        spring data redis reactive                          # 用户登录令牌的存储

  * 自定义过滤器：

        PrintCircuitGatewayFilterFactory                    # order = -301 输出日志开关

        PrintCircuitBaseOnApiGatewayFilterFactory           # order = -201 输出日志开关(根据GatewayApi动态配置)

        PrintRequestLineGatewayFilterFactory                # order = -101 输出请求line日志

        PrintRequestJsonBodyGatewayFilterFactory            # order = -100 输出请求json日志

        PrintResponseJsonBodyGatewayFilterFactory           # order = -100 输出响应json日志

        ModifyLoginResponseBodyGatewayFilterFactory         # order = -51  移动响应头登录令牌，移动到json body

        AuthenticateGatewayFilterFactory                    # 无 order 用户登录与权限验证、登录令牌生成到响应头、登录令牌存储和验证
