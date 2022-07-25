
# Jenkins 持续集成 简单总结

  * ①，清理构建空间：

        官方自带相关配置，或者使用 sh 执行命令即可，主要是防止当次构建被污染

  * ②，获取可发布资源：

        第一种，最常见的方式——使用源码进行构建，从 git/svn 拉取源码，使用 maven/gradle 进行编译打包

        第二种，可以使用 shell wget/curl 从 nexus 或 其他地址 拉取资源

  * ③-①，执行资源发布动作(jar)：

        原始部署方式，ssh 远程上传 application.jar、startup.sh 到服务器，并启动服务

  * ③-②，执行资源发布动作(docker)：

        第一步，执行源码携带的 docker-build.sh 将 application.jar 打包为容器镜像，然后上传到指定的镜像仓库

        第二步，传输启动脚本和配置：

            ①，使用 docker，将源码携带的 docker-deploy.sh 传输到目标服务器

            ②，使用 docker compose，将源码携带的 docker-compose-deploy.sh、docker-compose.yml 传输到目标服务器

            ③，使用 docker swarm，将源码携带的 docker-swarm-deploy.sh、docker-stack.yml传输到管理节点

        第三步，远程 ssh 执行目标服务器 deploy 脚本

  * ③-③，执行资源发布动作(kubernetes)：

        (jenkins + docker + kubernetes + helm，与 docker 相似，暂时不讨论)
