
# spring cloud gateway 统一登录验证鉴权

    源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

    项目模块：

        网关 mrh-spring-cloud-gateway                 延用 Part01 创建的网关

        服务 mrh-spring-cloud-api-admin               延用 Part01 创建的服务

        模块 mrh-spring-cloud-reference               存放服务共享定义

    引入组件：

        spring cloud bus amqp                         用于网关与服务之间的数据交换，降低网关与其他服务的耦合度

        spring boot redis                             用户登录令牌的存储

        json web token                                用户登录令牌生成工具

    自定义过滤器：

        DeployApiGatewayFilterFactory

        PrintRequestLineGatewayFilterFactory

        PrintRequestJsonBodyGatewayFilterFactory

        PrintResponseJsonBodyGatewayFilterFactory

        ModifyLoginResponseBodyGatewayFilterFactory

        AuthenticateGatewayFilterFactory

        CreateLoginTokenGatewayFilterFactory

    其他具体信息查看源码
