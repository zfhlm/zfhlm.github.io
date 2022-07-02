
# spring cloud gateway 登录验证鉴权

    源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

    项目模块：

        网关 mrh-spring-cloud-gateway                       # 延用 Part01 创建的网关

        服务 mrh-spring-cloud-api-admin                     # 延用 Part01 创建的服务

        模块 mrh-spring-cloud-reference                     # 存放服务共享定义

    引入组件：

        spring cloud bus amqp                               # 用于网关与服务之间的数据交换，降低网关与其他服务的耦合度

        json web token                                      # 用户登录令牌生成工具

        spring data redis reactive                          # 用户登录令牌的存储

    自定义过滤器：

        PrintCircuitGatewayFilterFactory                    # order = -301 输出日志开关

        PrintCircuitBaseOnApiGatewayFilterFactory           # order = -201 输出日志开关(根据GatewayApi动态配置)

        PrintRequestLineGatewayFilterFactory                # order = -101 输出请求line日志

        PrintRequestJsonBodyGatewayFilterFactory            # order = -100 输出请求json日志

        PrintResponseJsonBodyGatewayFilterFactory           # order = -100 输出响应json日志

        ModifyLoginResponseBodyGatewayFilterFactory         # order = -51  更改登录接口响应json，登录令牌从请求头移动到json body

        AuthenticateGatewayFilterFactory                    # 未指定 order 登录验证、权限验证、登录令牌生成和存储

    其他具体信息查看源码
