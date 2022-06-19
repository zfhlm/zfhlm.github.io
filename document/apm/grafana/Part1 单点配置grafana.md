
# 界面展示 grafana

### 相关文档

    下载地址：

        https://grafana.com/grafana/download

    文档地址：

        https://grafana.com/docs/grafana/next/

### 安装配置

    下载并解压安装包，输入命令：

        cd /usr/local/software

        wget https://dl.grafana.com/enterprise/release/grafana-enterprise-9.0.0.linux-amd64.tar.gz

        tar -zxvf grafana-enterprise-9.0.0.linux-amd64.tar.gz

        mv grafana-9.0.0/ ..

        cd ..

        ln -s ./grafana-9.0.0 grafana

        mkdir /usr/local/grafana/logs

    启动grafana，输入命令：

        # 前台进程启动
        ./bin/grafana-server web

        # 后台守护进程启动
        nohup ./bin/grafana-server web > /usr/local/grafana/logs/grafana.log 2>&1 &

    访问grafana：

        http://192.168.140.130:3000/

        账号密码 admin/admin

### 配置数据源

    1，首页点击【齿轮】图标，进入【Data sources】标签页

    2，点击【Add data source】进入添加数据源界面

    3，选择【Prometheus】数据源

    4，填写【Name】输入名称

    5，填写【URL】输入prometheus地址

    6，点击【Save & test】添加完成

### 配置展示面板

    1，选择合适的dashboard模板，地址 https://grafana.com/grafana/dashboards/

    2，例如 Node Exporter 数据展示，选择模板 https://grafana.com/api/dashboards/1860/revisions/27/download

    3，首页【Dashboard】-【Import】进入导入模板界面

    4，页面【Import via grafana.com】输入模板地址，点击【Load】（也可以下载模板JSON输入）

    5，填写【Name】名称

    6，点击【Prometheus】选择合适的数据源

    7，点击【Import】完成导入

    8，点击首页搜索图标，进入面板

    9，更改各个指标的title

    10，注意，dashboard一旦创建并选择了数据源，无法进行更换，可删除后再重建
