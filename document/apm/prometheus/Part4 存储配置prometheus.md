
# 存储配置 prometheus

### 使用外部存储

    prometheus 默认使用本地时序数据库进行数据读写操作，服务器断电或重启可能会导致 prometheus data 目录存储块损坏

    如果需要保证历史数据，需要配置远程读写，修改配置文件：

    
