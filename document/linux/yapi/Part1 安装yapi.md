
# 安装 yapi

    官网地址：https://hellosean1025.github.io/yapi/index.html

    Github地址：https://github.com/ymfe/yapi

#### 依赖环境配置：

        配置 nodejs

        配置 mongodb 并创建 yapi 数据库所属用户 root 密码 123456

#### 开始安装

    开启可视化部署，输入命令：

        npm install -g yapi-cli --registry https://registry.npm.taobao.org

        yapi server

    浏览器打开 web 页面执行可视化安装：

        浏览器打开页面 http://host:9090

        部署版本：1.10.2

        公司名称：xxxxxx

        部署路径：/usr/local/yapi/my-yapi

        管理员邮箱：admin@admin.com

        网站端口号：3000

        数据库地址：127.0.0.1

        数据库名称：yapi

        数据库认证：开启

        数据库用户名：root

        数据库密码：123456

        点击【开始部署】，等待部署完成

    修改配置文件，输入命令：

        cd /usr/local/yapi/my-yapi

        vi config.json

        {
           "port": "3000",
           "adminAccount": "admin@admin.com",
           "closeRegister":true,
           "db": {
              "servername": "127.0.0.1",
              "DATABASE": "yapi",
              "port": "27017",
              "user": "root",
              "pass": "123456"
           },
           "mail": {
              "enable": false,
              "host": "smtp.163.com",
              "port": 465,
              "from": "***@163.com",
              "auth": {
                 "user": "***@163.com",
                 "pass": "*****"
              }
           }
        }

    安装成功可能也会缺失包，下载确认，输入命令：

        cd /usr/local/yapi/my-yapi/vendors

        npm install --production --registry https://registry.npm.taobao.org --force

    配置管理员登录密码，输入命令：

        cd /usr/local/yapi/my-yapi/vendors

        npm run install-server

        -> 初始化管理员账号成功,账号名："admin@admin.com"，密码："ymfe.org"

    启动 yapi，输入命令：

        cd /usr/local/yapi/my-yapi

        node vendors/server/app.js

    使用浏览器访问页面：

        http://192.168.140.214:3000/login
