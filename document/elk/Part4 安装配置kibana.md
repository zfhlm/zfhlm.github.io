
# kibana

    es数据分析可视化平台

#### kibana 下载

    官方文档：https://www.elastic.co/guide/en/kibana/7.15/introduction.html

    下载地址：https://www.elastic.co/cn/downloads/past-releases#kibana

    下载安装包：kibana-7.15.1-linux-x86_64.tar.gz

    上传到服务器目录：/usr/local/software

#### kibana 安装

    解压安装包，输入命令：

        cd /usr/local/software

        tar -zxvf ./kibana-7.15.1-linux-x86_64.tar.gz

        mv ./kibana-7.15.1-linux-x86_64 ../kibana-7.15.1

        cd ..

        ln -s ./kibana-7.15.1 kibana

    更改配置文件，输入命令：

        vi ./config/kibana.yml

        =>

            server.name: kibana
            server.host: 192.168.140.192
            server.port: 5601
            elasticsearch.hosts: ["http://192.168.140.193:9200"]

    启动进程，输入命令：

        ./bin/kibana --allow-root

        nohup ./bin/kibana --allow-root > /dev/null 2>&1 &

    使用浏览器打开地址：

        http://192.168.140.192:5601/

#### kibana 使用 dev-tools

    进入 dev-tools 界面：导航栏【≡】->【Management】->【Dev Tools】

    使用 Console 发起请求，输入表达式，点击【▶】执行按钮，输入例如：

        GET /_search
        {
            "query": {
                "match_all": {}
            }
        }

    使用 Search Profiler 分析器查询，输入 index 和 表达式，点击【Profile】，输入例如：

        _all

        {
          "query":{
            "match_all" : {}
          }
        }

#### kibana 查询es数据

    第一步，创建索引模板：

        点击【D】->【Manage space】

        点击【Index patterns】->【Create index pattern】

            Name：输入 logstash-2021.10.20，名称匹配根据实际情况调整

            Timestamp field：选择 @timestamp

        填写完毕，点击【Create index pattern】提交

    第二步，使用索引模板进行查询：

        点击导航栏【≡】->【Discover】

        下拉框【Change index pattern】选中刚刚创建的索引模板

        左侧 Available fields 点击 + 选择要使用的查询条件

        上方输入框选择查询条件和查询日期段，点击【Refresh】即可查询
