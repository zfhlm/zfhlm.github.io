
# mysql集群多主MGR

#### 搭建多主 MGR

	和搭建主从MGR一样的流程，只需更改 my.cnf 以下配置：
		
		loose-group_replication_enforce_update_everywhere_checks=TRUE       #启用多主写验证
		loose-group_replication_single_primary_mode=OFF                     #关闭单主模式


