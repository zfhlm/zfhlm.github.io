
# docker 制作镜像 Dockerfile

### 构建指令

  * FROM

        指定基础镜像，格式为 FROM <image>:<tag>

        例如：

            FROM centos

            FROM nginx:1.21.3

  * RUN

        指定构建镜像执行命令，仅在构建镜像阶段有效，格式为 RUN <command> ... 或 RUN [<command>, ...]

        多行命令使用 && 连接，否则会构建多层镜像

        例如：

            RUN yum -y install wget \
                && wget -O tomcat.tar https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.72/bin/apache-tomcat-8.5.72.tar.gz \
                && tar -zxvf tomcat.tar

  * ARG

        定义构建参数，仅在构建镜像阶段有效，格式为 ARG <key>=<value>

        例如：

            ARG JAR_NAME tomcat.tar

  * WORKDIR

        指定当前工作目录，格式为 WORKDIR <path>

        例如：

            WORKDIR /usr/local/tomcat

            WORKDIR /usr/local/nginx

  * ADD

        添加文件到镜像目录，格式为 ADD [--chown=<user>:<group>] <fromPath>... <toPath>

        例如：

            ADD ./login.html /usr/local/tomcat/webapps/ROOT

  * COPY

        拷贝文件到镜像目录，格式为 COPY [--chown=<user>:<group>] <fromPath>... <toPath>

        例如：

            COPY ./index.html /usr/local/tomcat/webapps/ROOT

            COPY ./index.html ./css /usr/local/tomcat/webapps/ROOT

  * LABEL

        添加镜像描述信息，格式为 LABEL <key>=<value> <key>=<value> <key>=<value> ...

        例如：

            LABEL organization=personal email=abc@123.com author=zhangsan

  * ONBUILD

        指定延迟构建执行，格式为 ONBUILD <其它指令>

        例如：

            ONBUILD RUN echo 'hello'

  * VOLUME

        定义匿名挂载目录，格式为 VOLUME <path> 或 VOLUME [<path>, ...]

        例如：

            VOLUME /tmp/

            VOLUME ["/tmp", "/home/root"]

  * ENV

        定义环境变量，容器之内有效，格式为 ENV <key> <value> 或 ENV <key1>=<value1> <key2>=<value2>...

        例如：

            ENV PATH=1.0

  * EXPOSE

        定义运行容器暴露端口，格式为 EXPOSE <port>

        例如：

            EXPOSE 8080

            EXPOSE 8080 8090

  * USER

        定义执行命令的用户，格式为 USER <user>:<group>

        例如：

            USER root

            USER udev:dev

  * ENTRYPOINT

        指定运行容器执行命令定参，格式为 ENTRYPOINT [<command>, <param>, ...]

        例如：

            ENTRYPOINT ["startup.sh"]

  * CMD

        指定运行容器执行命令变参，多个最后一条有效，格式为 CMD <command> <param> ... 或 CMD [<command>, <param>, ...]

        例如：

            CMD ["java", "-jar", "springboot.jar"]

  * HEALTHCHECK

        指定容器监控检测命令，格式为 HEALTHCHECK [OPTIONS] CMD command 或 HEALTHCHECK NONE

        OPTIONS 可选参数 --interval=DURATION、--timeout=DURATION、--retries=N

        命令返回值 0 表示健康，返回 1 表示不能工作

        例如：

            HEALTHCHECK CMD /usr/bin/pkill -0 nginx

### 基于 openjdk 镜像构建 tomcat 镜像

  * 宿主机下载 tomcat 安装包，输入命令：

        yum -y install wget

        cd /usr/local/software

        wget https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.72/bin/apache-tomcat-8.5.72.tar.gz

  * 宿主机创建 Dockerfile 文件，输入命令：

        cd /usr/local/software

        vi Dockerfile

        =>

            FROM openjdk
            COPY ./apache-tomcat-8.5.72.tar.gz /usr/local/
            WORKDIR /usr/local/
            RUN tar -zxvf apache-tomcat-8.5.72.tar.gz \
                && mv apache-tomcat-8.5.72 tomcat \
                && rm -rf tomcat/webapps/* \
                && mkdir -p tomcat/webapps/ROOT \
                && echo "hello" >  tomcat/webapps/ROOT/index.html
            EXPOSE 8080 8009 8005
            CMD ["/usr/local/tomcat/bin/catalina.sh", "run"]

  * 宿主机构建 tomcat 镜像，并运行容器，输入命令：

        docker build -t tomcat:1.0 .

        docker run -d -it -p 8080:8080 --name tomcat tomcat:1.0

        docker ps

  * 宿主机访问tomcat，输入命令：

        curl http://localhost:8080

        -> hello

### 构建 springboot 项目镜像

  * springboot 启动类：

        @Controller
        @RequestMapping
        @SpringBootApplication
        public class Application {

            public static void main(String[] args) {
                SpringApplication.run(Application.class, args);
            }

            @GetMapping(path="/")
            @ResponseBody
            public String index() {
                return "hello";
            }

        }

  * springboot 配置文件 application.properties：

        server.port=8888

  * springboot maven 配置 pom.xml：

        <parent>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-parent</artifactId>
            <version>2.5.5</version>
        </parent>

        <dependencies>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter-web</artifactId>
            </dependency>
        </dependencies>

        <build>
            <finalName>application</finalName>
            <plugins>
                <plugin>
                    <groupId>org.springframework.boot</groupId>
                    <artifactId>spring-boot-maven-plugin</artifactId>
                    <configuration>
                        <layers>
                            <enabled>true</enabled>
                        </layers>
                    </configuration>
                </plugin>
            </plugins>
        </build>

  * springboot 项目根目录创建 Dockerfile，填写以下指令：

        (注意，如果不希望日志再次输出到docker，启动命令将日志输出重定向到 dev/null)

        FROM openjdk
        WORKDIR /usr/local/application/
        COPY target/application.jar application.jar
        EXPOSE 8888
        ENTRYPOINT ["java", "-jar","/usr/local/application/application.jar"]

  * 使用 maven 打包，再构建 docker 镜像，输入命令：

        (注意服务器配置好 jdk1.8、maven、docker 环境，将项目命名为 test 上传到服务器 /usr/local/ 目录)

        cd /usr/local/test/

        mvn clean package

        docker build -t application:1.0 .

        docker ps

  * 访问 springboot 接口：

        curl http://localhost:8888

        -> hello
