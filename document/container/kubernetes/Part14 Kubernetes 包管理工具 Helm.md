
# Kubernetes 包管理工具 Helm

  * 官方文档：

        https://github.com/helm/helm

        https://github.com/helm/helm/releases

        https://helm.sh/docs/intro/quickstart/

  * 主要概念：

        helm                    # 命令行工具

        Chart                   # 由 K8S 资源文件、Helm 配置文件组成的安装包

        Repository              # Chart 存储仓库

        Release                 # Chart 运行实例，每次安装都会创建一个新的 Release

  * 为什么要使用 Helm：

        当部署大量的资源对象 yaml 文件，在多环境、多版本的情况下，每次都要去修改各个 yaml 的版本、环境等配置，很容易出现错误

        Helm 可将镜像版本、部署环境参数等使用模板语言进行定义，在 Helm 发布的时候统一指定，并进行模板渲染，再发布到 k8s 集群，避免低级错误

## Helm 部署

  * 下载并解压安装包：

        cd /usr/local/software

        wget https://get.helm.sh/helm-v3.9.1-linux-amd64.tar.gz

        tar -zxvf helm-v3.9.1-linux-amd64.tar.gz

        mv linux-amd64/helm /usr/local/bin/helm

        helm --help

        -->

            The Kubernetes package manager

            Common actions for Helm:

            - helm search:    search for charts
            - helm pull:      download a chart to your local directory to view
            - helm install:   upload the chart to Kubernetes
            - helm list:      list releases of charts

            Environment variables:

            | Name                               | Description                                                                       |
            |------------------------------------|-----------------------------------------------------------------------------------|
            | $HELM_CACHE_HOME                   | set an alternative location for storing cached files.                             |
            | $HELM_CONFIG_HOME                  | set an alternative location for storing Helm configuration.                       |
            | $HELM_DATA_HOME                    | set an alternative location for storing Helm data.                                |
            | $HELM_DEBUG                        | indicate whether or not Helm is running in Debug mode                             |
            | $HELM_DRIVER                       | set the backend storage driver. Values are: configmap, secret, memory, sql.       |
            | $HELM_DRIVER_SQL_CONNECTION_STRING | set the connection string the SQL storage driver should use.                      |
            | $HELM_MAX_HISTORY                  | set the maximum number of helm release history.                                   |
            | $HELM_NAMESPACE                    | set the namespace used for the helm operations.                                   |
            | $HELM_NO_PLUGINS                   | disable plugins. Set HELM_NO_PLUGINS=1 to disable plugins.                        |
            | $HELM_PLUGINS                      | set the path to the plugins directory                                             |
            | $HELM_REGISTRY_CONFIG              | set the path to the registry config file.                                         |
            | $HELM_REPOSITORY_CACHE             | set the path to the repository cache directory                                    |
            | $HELM_REPOSITORY_CONFIG            | set the path to the repositories file.                                            |
            | $KUBECONFIG                        | set an alternative Kubernetes configuration file (default "~/.kube/config")       |
            | $HELM_KUBEAPISERVER                | set the Kubernetes API Server Endpoint for authentication                         |
            | $HELM_KUBECAFILE                   | set the Kubernetes certificate authority file.                                    |
            | $HELM_KUBEASGROUPS                 | set the Groups to use for impersonation using a comma-separated list.             |
            | $HELM_KUBEASUSER                   | set the Username to impersonate for the operation.                                |
            | $HELM_KUBECONTEXT                  | set the name of the kubeconfig context.                                           |
            | $HELM_KUBETOKEN                    | set the Bearer KubeToken used for authentication.                                 |

            Helm stores cache, configuration, and data based on the following configuration order:

            - If a HELM_*_HOME environment variable is set, it will be used
            - Otherwise, on systems supporting the XDG base directory specification, the XDG variables will be used
            - When no other location is set a default location will be used based on the operating system

            By default, the default directories depend on the Operating System. The defaults are listed below:

            | Operating System | Cache Path                | Configuration Path             | Data Path               |
            |------------------|---------------------------|--------------------------------|-------------------------|
            | Linux            | $HOME/.cache/helm         | $HOME/.config/helm             | $HOME/.local/share/helm |
            | macOS            | $HOME/Library/Caches/helm | $HOME/Library/Preferences/helm | $HOME/Library/helm      |
            | Windows          | %TEMP%\helm               | %APPDATA%\helm                 | %APPDATA%\helm          |

            Usage:
              helm [command]

            Available Commands:
              completion  generate autocompletion scripts for the specified shell
              create      create a new chart with the given name
              dependency  manage a chart's dependencies
              env         helm client environment information
              get         download extended information of a named release
              help        Help about any command
              history     fetch release history
              install     install a chart
              lint        examine a chart for possible issues
              list        list releases
              package     package a chart directory into a chart archive
              plugin      install, list, or uninstall Helm plugins
              pull        download a chart from a repository and (optionally) unpack it in local directory
              push        push a chart to remote
              registry    login to or logout from a registry
              repo        add, list, remove, update, and index chart repositories
              rollback    roll back a release to a previous revision
              search      search for a keyword in charts
              show        show information of a chart
              status      display the status of the named release
              template    locally render templates
              test        run tests for a release
              uninstall   uninstall a release
              upgrade     upgrade a release
              verify      verify that a chart at the given path has been signed and is valid
              version     print the client version information

            Flags:
                  --debug                       enable verbose output
              -h, --help                        help for helm
                  --kube-apiserver string       the address and the port for the Kubernetes API server
                  --kube-as-group stringArray   group to impersonate for the operation, this flag can be repeated to specify multiple groups.
                  --kube-as-user string         username to impersonate for the operation
                  --kube-ca-file string         the certificate authority file for the Kubernetes API server connection
                  --kube-context string         name of the kubeconfig context to use
                  --kube-token string           bearer token used for authentication
                  --kubeconfig string           path to the kubeconfig file
              -n, --namespace string            namespace scope for this request
                  --registry-config string      path to the registry config file (default "/root/.config/helm/registry/config.json")
                  --repository-cache string     path to the file containing cached repository indexes (default "/root/.cache/helm/repository")
                  --repository-config string    path to the file containing repository names and URLs (default "/root/.config/helm/repositories.yaml")

            Use "helm [command] --help" for more information about a command.

  * 配置存储仓库：

        helm search repo mysql

        -->

            No results found

        helm repo add stable http://mirror.azure.cn/kubernetes/charts

        helm repo add aliyun https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts

        helm repo update

        helm search repo mysql

        -->

            NAME                             CHART VERSION    APP VERSION    DESCRIPTION
            aliyun/mysql                     0.3.5                           Fast, reliable, scalable, and easy to use open-...
            stable/mysql                     0.3.5                           Fast, reliable, scalable, and easy to use open-...
            aliyun/percona                   0.3.0                           free, fully compatible, enhanced, open source d...
            aliyun/percona-xtradb-cluster    0.0.2            5.7.19         free, fully compatible, enhanced, open source d...
            stable/percona                   0.3.0                           free, fully compatible, enhanced, open source d...
            stable/percona-xtradb-cluster    0.0.2            5.7.19         free, fully compatible, enhanced, open source d...
            aliyun/gcloud-sqlproxy           0.2.3                           Google Cloud SQL Proxy
            aliyun/mariadb                   2.1.6            10.1.31        Fast, reliable, scalable, and easy to use open-...
            stable/gcloud-sqlproxy           0.2.3                           Google Cloud SQL Proxy
            stable/mariadb                   2.1.6            10.1.31        Fast, reliable, scalable, and easy to use open-...

## Helm 模板

  * 模块目录结构：

        mychart/
        +---- Chart.yaml                            # 文件，Chart 的描述
        +---- values.yaml                           # 文件，用于存储 templates 目录中模板文件中用到变量的值
        +---- charts                                # 目录，用于存放依赖 Charts
        +---- templates                             # 目录，用于存放 K8S 资源文件目录
             +---- _helpers.tpl                     # 放置可以通过chart复用的模板辅助对象
             +---- NOTES.txt                        # Chart 安装辅助文本描述信息
             +---- deployment.yaml                  # 资源文件
             +---- service.yaml                     # 资源文件
             +---- pod.yaml                         # 资源文件
             +---- ...                              # 资源文件

  * 创建 chart 空模板：

        cd /usr/local/software

        # 先创建一份默认的模板
        helm create mrh-cluster

        cd templates

        # 删除多余的配置文件
        rm -rf deployment.yaml  hpa.yaml ingress.yaml serviceaccount.yaml service.yaml tests

        # 清空默认配置信息
        echo '' > ../values.yaml && echo '' > NOTES.txt

        cd /usr/local/software

        # 输出渲染后的模板信息，注意不会进行安装
        helm install --debug --dry-run mrh-cluster ./mrh-cluster/

  * 添加 chart 资源对象配置：

        cd /usr/local/software/templates

        vi namespace.yaml

        ==>

            apiVersion: v1
            kind: Namespace
            metadata:
              name: mrh-cluster
              labels:
                created-by: mrh
                website: zfhlm.github.io

        vi centos-pod.yaml

        ==>

            apiVersion: v1
            kind: Pod
            metadata:
              name: centos
              namespace: mrh-cluster
              labels:
                cluster: mrh-cluster
                service: centos
                created-by: mrh
                website: zfhlm.github.io
            spec:
              restartPolicy: Always
              containers:
              - name: centos
                # 引用 values.yaml 中定义的属性
                image: centos:{{ .Values.centos.version }}
                imagePullPolicy: IfNotPresent
                command: ['/bin/sh', '-c', '/usr/sbin/init']

        cd ..

        vi values.yaml

        ==>

            # 以下属性可以使用 {{ .Values.centos.version }} 引用
            centos:
              version: centos7

        vi Chart.yaml

        ==>

            # 注意更改为与发布版本一致的版本号
            version: 1.0.1

  * 发布 chart 资源：

        cd /usr/local/software

        helm upgrade -i --debug --dry-run mrh-cluster ./mrh-cluster/

        # 参数 -i 无则创建，有则更新
        helm upgrade -i mrh-cluster ./mrh-cluster/

## Helm Nginx 私库

  * 安装 Nginx 并配置 /usr/local/helm/charts 为根目录：

        (略)

  * 创建 Helm 打包并上传到私库：

        cd /usr/local/software

        # 打包
        helm package mrh-cluster/

        # 移动到私库目录
        mv mrh-cluster-1.0.1.tgz /usr/local/helm/charts

        # 创建或刷新索引(注意每次上传新的安装包都要刷新索引)
        helm repo index .

  * 使用私库安装包：

        helm repo add local http://192.168.140.140

        helm repo update

        helm repo list

        -->

            NAME      URL
            stable    https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
            aliyun    https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
            local     http://192.168.140.140

        helm search repo mrh

        -->

            NAME                  CHART VERSION     APP VERSION     DESCRIPTION
            local/mrh-cluster     1.0.1             1.16.0          A Helm chart for Kubernetes
            local/mrh-test        0.1.0             1.16.0          A Helm chart for Kubernetes

        # 指定版本部署
        helm upgrade -i mrh-cluster local/mrh-cluster --version=1.0.1

## Helm Chartmuseum 私库
