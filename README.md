CoreOS with Kubernetes

```
$ ./generate.rb
$ packer validate korekube.json
$ packer build -var 'aws_access_key=...' -var 'aws_secret_key=...' \
        -var 'vpc_id=vpc-xxxx' -var 'subnet_id=subnet-xxxx' korekube.json
```

