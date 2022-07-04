
# spring cloud gateway 登录验证鉴权

### 相关文档

  * 官方文档地址：

        https://docs.spring.io/spring-cloud/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/

        https://docs.spring.io/spring-cloud-bus/docs/current/reference/html/

        https://jwt.io/introduction/

  * 示例源码地址：

        https://github.com/zfhlm/mrh-example/tree/main/mrh-spring-cloud

### 网关鉴权

  * 权限服务发布权限信息包括：

        接口信息 GatewayApi

        角色信息 GatewayRole

        角色可调用接口信息 GatewayRole.Apis

  * 网关启动获取权限信息流程

        网关                               消息总线                            权限服务
        |   publish started event             |                                     |
        |------------------------------------>|       receive started event         |
        |                                     |------------------------------------>|
        |                                     |                                     |
        |                                     |       publish permission event      |
        |   receive permission event          |<------------------------------------|
        |<------------------------------------|                                     |
        |refresh api and role cache           |                                     |

  * 权限服务启动、权限更改，发布权限流程

        权限服务                           消息总线                                网关
        |   publish permission event          |                                     |
        |------------------------------------>|    receive permission event         |
        |                                     |------------------------------------>|
        |                                     |           refresh api and role cache|

  * 用户登录验证、权限验证、令牌生成流程：

        (令牌先获取、解析、鉴权，最后才验证是否已废弃，考虑到如果 token 使用 redis 存储有网络开销，所以放到最后进行)

        ..................................................网关................................................................
        |request    allow anonymous                                                                                          |
        |-------->|--------------------------------------------------------------------------------------------------------->|
        |         |                                                                                                          |
        |         | not allow anonymous                                                                                      |
        |         |--------------------->| get token                                                                         |
        | token not exist                |---------->|                                                                       |
        |<-------------------------------------------| parse token                                                           |
        | wrong or expired token                     |------------>|                                                         |
        |<---------------------------------------------------------| permission valid                                        |
        | no permission                                            |----------------->|                                      |
        |<----------------------------------------------------------------------------| token discard valid                  |
        | discarded token                                                             |------------>|                        |
        |<------------------------------------------------------------------------------------------|add user info to header |
        |                                                                                           |----------------------->|request
        |                                                                                                                    |------->
        |                                                                                                   is login api     |<-------
        |                                                                   get user info from header |<---------------------|response
        |                                generate token and add to header |<--------------------------|                      |
        |  add token to response body  |<---------------------------------|                                                  |
        |<-----------------------------| store token                                                                         |
        |                                                                                                   not login api    |
        |<-------------------------------------------------------------------------------------------------------------------|
