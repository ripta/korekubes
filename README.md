CoreOS with Kubernetes

```
$ ./generate.rb
$ packer validate korekube.json
$ packer build -var 'aws_access_key=...' -var 'aws_secret_key=...' korekube.json
```

