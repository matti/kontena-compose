# kontena-compose

aka "mini-kontena" -- Run Kontena with docker-compose in production with docker-compose

Tested with: coreos stable (01/21/2017) and ubuntu 16.04

## Setup locally on docker-machine

### Master
```
cd master                              # to master/ directory
bin/initialize                         # this will start to tail logs, you can exit safely with ^C

cd ..                                  # (to project root)
bin/setup http://192.168.99.100:9292   # Do the master setup dance with Kontena Cloud
```

### Node

Start node in the same (docker-)machine with the master:

```
cd node && bin/initialize 1.0.4 ws://192.168.99.100:9292  # Safe to ^C
cd ..
watch -n 1 kontena node ls
kontena service create redis redis
kontena service scale redis 1
```

### Teardown
```
cd node && bin/destroy && cd ..
cd master && bin/destroy && cd ..

bin/destroy                            # Remove master from local kontena cli and cloud
```

## Setup on remote host

Ensure you have ssh access to the machines and:

### Master
```
bin/remote_deploy master MASTERHOSTNAME
bin/remote_initialize master MASTERHOSTNAME
```

### Node
```
bin/remote_deploy node NODEHOSTNAME
bin/remote_initialize node NODEHOSTNAME 1.0.4 MASTERHOSTNAME
kontena service create redis redis
kontena service scale redis 3
```

## Teardown

```
bin/remote_destroy node NODEHOSTNAME
bin/remote_destroy master MASTERHOSTNAME
```

Clean docker (everything):
```
bin/remote_destroy docker NODEHOSTNAME
bin/remote_destroy docker MASTERHOSTNAME
```


# PRO-TIPS

## Let's Encrypt cert for master

```
# only for remote (let's encrypt needs to talk)
bin/remote_initialize master MASTERHOSTNAME 1.0.4 localhost master.yourdomain.com letsencrypt@notifications.com
```

## ETCD over public network (expose weave port)

```
kontena node add FIRSTNODENAME region=other-region
```

## Trigger CoreOS update

```
update_engine_client -check_for_update
journalctl -f
```