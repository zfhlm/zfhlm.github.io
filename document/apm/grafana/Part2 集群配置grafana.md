
# 集群配置 grafana

### 相关文档

    下载地址：

        https://grafana.com/grafana/download

    文档地址：

        https://grafana.com/docs/grafana/next/

### 集群配置

  * 更改 grafana 存储数据源，输入命令：

        cd /usr/local/grafana

        vi conf/defaults.ini

        =>

            [database]
            type = mysql
            host = 192.168.140.130:3306
            name = grafana
            user = root
            password = 123456
            url = mysql://root:123456@192.168.140.130:3306/database
            max_idle_conn = 20

  * 更改 grafana 缓存数据源，输入命令：

        cd /usr/local/grafana

        vi conf/defaults.ini

        =>

            [remote_cache]
            type = database
            connstr = root:123456@tcp(192.168.140.130:3306)/grafana

  * 使用 nginx 代理多节点：

        upstream grafana_lb {
            ip_hash;
            server 192.168.140.130:3000;
            server 192.168.140.131:3000;
        }

        server {

            listen 13000;
            server_name localhost;
            proxy_redirect off;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_connect_timeout 30s;
            proxy_read_timeout 30s;

            location / {
                 proxy_pass http://grafana_lb/;
            }

        }
