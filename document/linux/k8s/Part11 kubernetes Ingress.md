    apiVersion: v1
    kind: Pod
    metadata:
      name: centos
    spec:
      containers:
      - name: centos
        image: centos
        command: ['/usr/sbin/init']
