
# 自定义统计面板 grafana

### 相关文档

    下载地址：

        https://grafana.com/grafana/download

    文档地址：

        https://grafana.com/docs/grafana/next/

### 自定义统计面板

  * 创建面板

        进入已创建 dashboard

        点击顶部 Add panel

        选择合适的图表类型

  * 定义指标

        编辑 Query patterns 一栏

        输入 Metric 选择统计的指标项，例如：http_server_requests_seconds_count

        添加 Labels 进行过滤，例如：cluster=mrh-cluster

        添加指标处理函数，可以使用多个，可以调整函数执行顺序，例如：

            使用 sum by 参数 label=instance 计算 instance 多条数据之和

            使用 Last over time 参数 Range=$__interval 计算最后一个指标值

            使用 increase 参数 Range=$__interval 计算数据间隔时间内的增量

        指标处理函数也可以直接编写：

            sum by(instance) (http_server_requests_seconds_count{cluster="mrh-cluster"})

        完成点击保存

  * 查看面板

        回到 dashboard 界面

        调整 panel 的大小和位置

        如需要更改，点击标题对 panel 进行编辑
