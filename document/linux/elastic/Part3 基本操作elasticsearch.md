
# 使用 elasticsearch

    以下操作基于 kibana 进行，以下示例不对 PUT/POST 进行语义区分

#### 集群状态

    查看集群健康状态：

        GET /_cat/health?v

    查看集群所有节点：

        GET /_cat/nodes?v

    查看集群主节点：

        GET /_cat/master?v

    查看集群索引：

        GET /_cat/indices?v

#### 模板操作

    查询所有模板：

        GET /_template

    查询指定名称模板：

        GET /_template/{template_name}

    创建或更新指定名称模板：

        PUT _index_template/{template_name}
        {
            "index_patterns": ["{template_name}-*"],
            "template": {
                "settings": {
                    "number_of_shards": 1
                }
            }
        }

    删除指定名称模板：

        DELETE _index_template/{template_name}

#### 索引操作

    查询索引：

        GET /{index_name}

    创建或更新索引：

        PUT /{index_name}
        {
            "settings": {
                "number_of_shards": 1,
                "number_of_replicas": 1
            }
        }

    删除索引：

        DELETE /{index_name}

    开启索引：

        POST /{index_name}/_open

    关闭索引：

        POST /{index_name}/_close

#### 文档更新操作

    添加文档(覆盖添加)：

        PUT /{index_name}/_doc/{id}
        {
            "name": "张三",
            "gender": "男"
        }

    添加文档(不允许覆盖)：

        PUT /{index_name}/_doc/{id}/_create
        {
            "name": "张三",
            "gender": "男"
        }

    删除文档(根据id删除)：

        DELETE /{index_name}/_doc/{id}

    删除文档(条件删除)：

        DELETE /{index_name}/_doc//_query
        {
            "query": {
                ....
            }
        }

#### 文档查询操作

    查询主要有以下几种条件：

        分页条件：指定位置开始，查询指定条数

        匹配条件：匹配条件使用的是contains而不是equals，匹配又分为两种：match分词匹配(分词部分满足条件)、term不分词匹配

        排序条件：默认使用相关性进行排序，keyword类型字段可以用于升序或降序

        多条件组合：使用 bool 的 must、must_not、should、filter 进行组合匹配

    分页条件：

        # 第一页，查询从位置0开始，查询10条
        POST /student/_doc/_search
        {
          "from": 0,
          "size": 10
        }

        # 第二页，查询从位置10开始，查询10条
        POST /student/_doc/_search
        {
          "from": 10,
          "size": 10
        }

    match分词匹配条件：

        # 分词匹配名字为张三的文档，可以查询出张三
        POST /student/_doc/_search
        {
            "query":{
                "match": {
                    "name": "张三"
                }
            }
        }

        # 分词匹配名字为张啊三的文档，可以查询出张三
        POST /student/_doc/_search
        {
            "query":{
                "match": {
                    "name": "张啊三"
                }
            }
        }

    term不分词匹配条件：

        # 不分词匹配名字为张三的文档，可以查询出张三
        POST /student/_doc/_search
        {
            "query":{
                "term": {
                    "name": "张三"
                }
            }
        }

        # 不分词匹配名字为张啊三的文档，查询结构为空
        POST /student/_doc/_search
        {
            "query":{
                "term": {
                    "name": "张啊三"
                }
            }
        }

    排序条件：

        # 根据名称升序
        POST /student/_doc/_search
        {
            "sort": [
                {
                    "name": { "order": "asc" }
                }
            ]
        }

        # 根据名称降序，性别升序
        POST /student/_doc/_search
        {
            "sort": [
                {
                    "name": { "order": "desc" }
                },{
                    "gender": { "order": "asc" }
                }
            ]
        }

    多条件组合：

        # 名称匹配张三，性别为男
        POST /student/_doc/_search
        {
            "query": {
                "bool": {
                    "must":[
                        {
                            "match": { "name": "张三" }
                        },
                        {
                            "match": { "gender": "男" }
                        }
                    ]
                }
            }
        }
