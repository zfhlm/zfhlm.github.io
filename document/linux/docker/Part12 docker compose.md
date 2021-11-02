
# docker compose

	docker compose 用于定义和运行多容器Docker应用程序的工具，使用 yaml 文件进行容器编排

	注意，只有 docker compose 而不配合 docker swarm 只能实现单主机容器编排

	官方文档：

		https://docs.docker.com/compose/

		https://github.com/compose-spec/compose-spec/blob/master/spec.md

### 下载安装

	下载执行脚本，输入命令：

		cd /usr/local/software

		wget -O docker-compose https://github.com/docker/compose/releases/download/v2.0.1/docker-compose-linux-x86_64

	配置执行脚本，输入命令：

		mkdir -p /usr/lib/docker/cli-plugins/

		mv ./docker-compose /usr/lib/docker/cli-plugins/

		chmod +x /usr/lib/docker/cli-plugins/docker-compose

		ln -s /usr/lib/docker/cli-plugins/docker-compose /usr/bin/docker-compose

	查看是否成功，输入命令：

		docker-compose --version

		-> Docker Compose version v2.0.1

### yaml

	docker compose 配置文件命令：

		compose.yaml

		compose.yml

	docker compose 配置文件顶层由以下几部分组成：

		version           # 定义验证配置文件版本号

		networks          # 定义容器可用的网络配置(可选)

		volumes           # 定义容器可用的挂载目录(可选)

		configs           # 定义容器可用的运行配置文件(可选)

		secrets           # 定义容器可用的密码信息(可选)

		services          # 定义从打包镜像到运行容器的配置

	以上配置，networks、volumes、configs、secrets 定以后，供给最核心配置 services 引用

### yaml version

	根据 docker 引擎的版本填写，对应的关系如下：

		3.8 => 19.03.0+
		3.7 => 18.06.0+
		3.6 => 18.02.0+
		3.5 => 17.12.0+
		3.4 => 17.09.0+
		3.3 => 17.06.0+
		3.2 => 17.04.0+
		3.1 => 1.13.1+
		3.0 => 1.13.0+
		2.4 => 17.12.0+
		2.3 => 17.06.0+
		2.2 => 1.13.0+
		2.1 => 1.12.0+
		2.0 => 1.10.0+

	在 docker compose 宿主机输入命令确定 docker 引擎版本号，输入命令：

		docker --version

		-> Docker version 20.10.10, build b485636

	如果当前本机版本号 20.10.10，使用以下配置：

		version: '3.8'

### yaml networks

	定义多个不同的网络，格式：

		networks:
		  <net-name>:
		  <net-name>:
		     ...
		  <net-name>:

		# 示例
		networks:
		  overlay:
		  ipvlanl2:
		  macvlan:
		  my-net:

	参数 driver 用于定义网络网卡 driver，必须为合法的 driver，格式：

		networks:
		  <net-name>:
		    driver: <driver-name>

		# 示例
		networks:
		  bridge-net:
		    driver: bridge
		  overlay-net:
		    driver: overlay
		  host-net:
		    driver: host
		  none-net:
		    driver: none
		  ipvlanl2-net:
		    driver: ipvlan

	参数 external、name 用于定义外部已存在的网络，格式：

		networks:
		  <net-name>:
		    external: <boolean>
		    name: <network>

		# 示例
		networks:
		  overlay-net:
		    external: true
		    name: overlay
		  ipvlanl2-net:
		    external: true
		    name: ipvlanl2
		  macvlan-net:
		    external: true
		    name: macvlan

	参数 driver_opts 定义传递给网卡驱动参数，格式：

		networks:
		  <net-name>:
		    driver_opts:
		      <name>: <value>
		      <name>: <value>
		        ...
		      <name>: <value>

		networks:
		  <net-name>:
		    driver_opts:
		      - <name>=<value>
		      - <name>=<value>
		      -  ...
		      - <name>=<value>

	参数 attachable 定义是否网络可以连接的，格式：

		networks:
		  <net-name>:
		    attachable: <boolean>

	参数 enable_ipv6 定义是否网络启用 ipv6，格式：

		networks:
		  <net-name>:
		    enable_ipv6: <boolean>

	参数 ipam 定义网络地址管理(ip address manage)，ipam包含多个子配置：

		ipam.driver                  #网络驱动
		ipam.config.subnet           #网段
		ipam.config.ip_range         #分配IP段
		ipam.config.gateway          #网关
		ipam.config.aux_addresses    #备用IP列表
		ipam.options                 #网络驱动参数

		networks:
		  <net-name>:
		    driver: <driver>
		    config:
		      subnet: <subnet>
		      ip_range: <ip_range>
		      gateway: <gateway>
		      aux_addresses: <aux_addresses>
		      options:
		        - <name>=<value>
		        - <name>=<value>
		        - ...
		        - <name>=<value>

	参数 internal 定义是否允许创建外部网络，格式：

		networks:
		  internal: <boolean>

	参数 external 定义是否不允许创建外部网络，格式：

		networks:
		  external: <boolean>

	参数 labels 定义元信息，格式：

		networks:
		  labels:
		    - <name>=<value>
		    - <name>=<value>
		    - ...
		    - <name>=<value>

### yaml volumes

	定义多个挂载目录，格式：

		volumes:
		  <volume-name>:
		       ...
		  <volume-name>:
		  <volume-name>:

		# 示例
		volumes:
		  mysql-data:
		  mysql-logs:
		  app-logs:

	参数 driver、driver_opts 定义挂载目录驱动及其参数，格式：

		volumes:
		  <volume-name>:
		    driver: <name>
		    driver_opts:
		      - <name>=<value>
		      - <name>=<value>
		      - ...
		      - <name>=<value>

	参数 external 定义是否允许自动创建挂载目录，格式：

		volumes:
		    <volume-name>:
		      external: <boolean>

	参数 labels 定义挂载目录元数据，格式：

		volumes:
		  <volume-name>:
		    labels:
		      - <name>=<value>
		      - <name>=<value>
		      - ...
		      - <name>=<value>

	参数 name 定义挂载目录引用名称，格式：

		volumes:
		  <volume-name>:
		    name: <name>

### yaml configs

	
