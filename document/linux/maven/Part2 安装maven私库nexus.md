
#### 搭建nexus

    服务器地址：192.168.140.140

    1，配置JDK1.8及其环境变量

    2，下载nexus最新版本安装包，地址：

        http://www.sonatype.org/nexus/go/

    3，解压nexus安装包：

        cd /usr/local

        mkdir nexus

        cd /usr/local/software

        tar -zxvf ./nexus-3.4.0-02-unix.tar.gz

        mv nexus-3.4.0-02/ /usr/local/nexus/

        mv sonatype-work/ /usr/local/nexus/

        cd /usr/local/nexus/

        ln -s ./nexus-3.4.0-02 nexus

    4，配置nexus

        允许root用户运行：

            cd /usr/local/nexus/nexus/bin

            vi nexus.rc

            更改配置文件内容： run_as_user=root

        更改运行端口：

            cd /usr/local/nexus/nexus/etc

            vi nexus-default.properties

        启动nexus：

            cd /usr/local/nexus/nexus/bin

            ./nexus start

            ./nexus status

    5，访问nexus：

        浏览器输入地址：

            http://192.168.140.140:8081/

    6，修改密码：

        点击 Sign in

        登录账号/密码：admin/admin123

        点击导航栏admin进入个人信息更改界面

#### 创建本地私库

    1，清除多余的自带库：

        点击【Repositories】

        将除了 maven-central、maven-public、maven-releases、maven-snapshots 之外的库都删除

    2，创建存储：

        点击【Blob stores】

        点击【Create blob store】

        输入名称和路径，路径可以使用默认路径，提交保存即可.

    3，创建本地存储私库：

        点击【Repositories】

        点击【Create repository】

        选择【maven2(hosted)】

            其中有三种类型的maven2仓库

            maven2(group)：聚合组仓库

            maven2(hosted)：本地存储仓库

            maven2(proxy)：代理远程仓库

        填写创建信息：

            【Name】：自定义名称，应该根据后面的类型加上后缀，例如 mrh-releases、mrh-snapshots

            【Online】：使用默认的即可

            【Version policy】：按需选择，Release为正式发布版本库，Snapshot为快照库，Mixed为混合库

            【Layout policy】：使用默认的即可

            【Blob store】：选择自定义的，或者使用默认的

            【Strict Content Type Validation】：使用默认的即可

            【Deployment policy】：是否可以重复发布，按需选择 Allow redeploy、Disable redeploy、Read-only 三种类型

        提交保存即可.

    4，创建本地聚合私库：

        根据步骤3，创建好自定义的 releases 私库和 snapshots 私库，例如名称为 mrh-releases、mrh-snapshots

        点击【Repositories】

        点击【Create repository】

        选择【maven2(group)】

        填写创建信息：

            【Name】：填写名称，可以按照maven的命名规则，例如 mrh-public

            【Online】：使用默认的即可

            【Blob store】：选择自定义的，或者使用默认的

            【Strict Content Type Validation】：使用默认的即可

            【Member repositories】：选择需要聚合的仓库，提交到 Members

        提交保存即可.

#### 创建私库账号

    1，创建私库角色

        点击【Security】

        点击【Roles】

        点击【Create role】，选择【Nexus role】

        填写创建信息：

            【Role ID】：填写角色唯一ID，一般跟随角色管理的仓库名称，例如 mrh-developer

            【Role name】：角色名称，与 role ID 一致即可

            【Role description】：角色描述，按需填写

            【Privileges】：根据仓库名称作筛选，例如filter输入mrh，选择筛选出的权限，提交到Given栏

            【Roles】：角色继承，一般不选择

        然后点击【Create role】 按钮即创建成功

    2，创建私库用户

        点击【Security】

        点击【Users】

        点击【Create user】

        填写创建信息：

            【ID】：账号唯一ID，作为登录账号

            【First name】：姓

            【Last name】：名

            【Email】：邮箱地址

            【Password】：登录密码

            【Confirm password】：确认登录密码

            【Status】：选择激活或者禁用(Active/Disabled)，一般选择Active

            【Roles】：角色，选择需要赋予的角色

        然后点击【Create user】按钮即创建成功

#### maven配置私库下载

    1，打开maven的 setting.xml 配置文件，更改以下信息：

        <mirrors>
            <!-- 私库代理maven中央库 -->
            <mirror>
                <id>maven-public</id>
                <name>maven-public</name>
                <mirrorOf>*</mirrorOf>
                <url>http://192.168.140.140:8081/repository/maven-public/</url>
            </mirror>
            <!-- 自定义私库 -->
            <mirror>
                <id>mrh-public</id>
                <name>mrh-public</name>
                <mirrorOf>*</mirrorOf>
                <url>http://192.168.140.140:8081/repository/mrh-public/</url>
            </mirror>
        </mirrors>

    2，使用 mvn 命令，或者其他 maven 项目测试

    3，下载完毕，回到 nexus 界面，在【Browse】-【Components】，点开仓库可以查看到已下载的包被缓存到了私库

#### 手动上传jar包到私库

    1，在nexus管理界面，创建一个名称为 maven-third-party 的Mixed类型私库

    2，打开maven的 setting.xml 配置文件，加入nexus账号信息：

        <server>
            <id>maven-third-party</id>
            <username>admin</username>
            <password>admin123</password>
        </server>

        其中，id表示maven私库的ID，username账号，password密码，可以配置其他有私库相关权限的账号

    3，使用maven命令上传jar包：

        假设jar包信息：

            磁盘位置：F:\commons-lang3-1.0.jar
            组织名：org.apache.commons
            包名称：commons-lang3
            版本号：1.0

        maven命令：

            mvn deploy:deploy-file
            -DgroupId=org.apache.commons
            -DartifactId=commons-lang3
            -Dversion=1.0
            -Dpackaging=jar
            -Dfile=F:\commons-lang3-1.0.jar
            -Durl=http://192.168.140.140:8081/repository/maven-third-party/  
            -DrepositoryId=maven-third-party

#### maven项目打包发布到私库

    1，创建好正式版本库、快照版本库、集合组库：

        http://192.168.140.140:8081/repository/mrh-releases/

        http://192.168.140.140:8081/repository/mrh-snapshots/

        http://192.168.140.140:8081/repository/mrh-public/

    2，maven的 setting.xml 加入有权限发布版本包的私库账号配置信息：

        <server>
            <id>mrh-releases</id>
            <username>admin</username>
            <password>admin123</password>
        </server>
        <server>
            <id>mrh-snapshots</id>
            <username>admin</username>
            <password>admin123</password>
        </server>

    3，maven项目的 pom.xml 加入发布私库的私库配置信息：

        <distributionManagement>
            <repository>
                <id>mrh-releases</id>
                <name>Releases</name>
                <url>http://192.168.140.140:8081/repository/mrh-releases/</url>
            </repository>
            <snapshotRepository>
                <id>mrh-snapshots</id>
                <name>Snapshot</name>
                <url>http://192.168.140.140:8081/repository/mrh-snapshots/</url>
            </snapshotRepository>
        </distributionManagement>

        注意：<repository> 和 <snapshotRepository> 子节点 <id>，对应 maven 配置文件 setting.xml 中 <server> 子节点 <id>

    4，打包发布项目到私库：

        maven项目信息：

            　<groupId>org.lushen.mrh</groupId>
              <artifactId>test</artifactId>
              <version>1.0.RELEASE</version>
              <!-- <version>1.0-SNAPSHOT</version> -->

        maven执行命令：

            mvn clean deploy -Dmaven.test.skip=true

            maven会根据项目的version中是否带有-SNAPSHOT来判断是快照版本还是正式版本
