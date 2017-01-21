# kontena-compose

aka "mini-kontena" -- Run Kontena with docker-compose in production with docker-compose

Tested with: coreos stable (01/21/2017) and ubuntu 16.04

## Setup
Ensure you have ssh access to the machines and:

```
bin/remote_deploy master MASTERHOSTNAME
bin/remote_initialize master MASTERHOSTNAME
bin/setup http://MASTERHOSTNAME:9292

kontena service create redis redis
kontena service scale redis 3
```

```
bin/remote_deploy node NODEHOSTNAME
bin/remote_initialize node NODEHOSTNAME 1.0.4 MASTERHOSTNAME
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