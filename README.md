# kontena-compose

Setups a remote host with SSH to run Kontena with docker-compose.

Tested with: Ubuntu 16.04
Providers tested: boot2docker, Azure, OVH, but should work with any provider (as it's just SSH and docker-compose)

CoreOS support needs some fixing on the CoreOS itself: https://github.com/kontena/kontena/blob/master/cli/lib/kontena/machine/cloud_config/cloudinit.yml#L22-L40

## Setup

Requires Ruby so `bundle install` first.

Make your host(s) accessible with SSH by having `.ssh/config` setup.

For example if you want to run locally on docker-machine:

```
Host docker-machine
  HostName 192.168.99.100
  User docker
  IdentityFile ~/.docker/machine/machines/default/id_rsa
```

Or any remote host:

```
Host your-remote-host
  HostName 123.123.123.123
  User core
```

Verify that `ssh your-remote-host` works without a password.

## Installing master

`bin/initialize` deploys files required (using `bin/deploy`) to the target machine and runs initialization of `master` or `node`

```
# To use the defaults (:latest Kontena etc)
bin/initialize remote-host-in-ssh-config master

# .. or to specify a version:
bin/initialize remote-host-in-ssh-config master --kontena_version 1.0.6

# .. or to create a certificate automagically with Let's Encrypt SSL:
bin/initialize remote-host-in-ssh-config master \
  --kontena_version 1.0.6 \
  --master_le_cert_hostname myhostname-that-points-to-the-public-ip-of-master.example.com \
  --master_le_cert_email notifications@fromletsencryptaresenthere.com

# .. for even more settings:
bin/initialize remote-host-in-ssh-config master --help
```


Master will boot and then logs will be shown -- hit ^C when the master has booted (will only disconnect from logs that can be seen with `bin/logs remote-host-in-ssh-config master`)

If you want to see more logs, use `bin/logs remote-host-in-ssh-config master --help`

Then you'll login to the master, add your user as the admin and create a grid:

```
# To use the defaults (creates a grid called kontenacompose with ETCD initial size 1)
bin/setup_master http(s?)://public_ip_or_hostname_of_the_master your.kontena@cloud.email.com

# .. or to specify settings:
bin/setup_master http(s?)://public_ip_or_hostname_of_the_master your.kontena@cloud.email.com \
  --master_name mymaster \
  --grid_name mygrid \
  --grid_initial_size 3 \
  --grid_token mybettertoken
```

## Adding node(s)

```
# To use the defaults (connects to master running in ws://localhost (one machine will be both master and node))
bin/initialize remote-host-in-ssh-config node

# .. or to specify settings
bin/initialize remote-host-in-ssh-config node \
  --kontena_version 1.0.6 \
  --master_uri ws(s?)://public_ip_or_hostname_of_the_master \
  --grid_token mybettertoken
```

Hit ^C when the agent has connected and wait for the agent to join:

```
watch -n 1 kontena node ls
```

Test your grid:

```
kontena service create redis redis
kontena service scale redis 2
kontena service logs redis
```

### Teardown

To remove nodes (run docker-compose down) use:
```
bin/destroy remote-node1-in-ssh-config node1
bin/destroy remote-node2-in-ssh-config node2
```

To remove master AND the entry for the master in Kontena Cloud use:
```
bin/destroy remote-master-in-ssh-config master
```

Optionally to completely clean everything (containers and images) from Docker:
```
bin/destroy remote-host-in-ssh-config docker
```

## Testing

```
ruby test/defaults.rb docker-machine http://192.168.99.100 admin@email.com
```

## PRO-TIPS

### ETCD over public network (expose weave port)

If you don't expose all ports to all nodes, then the traffic will be routed as multi-hop.

```
kontena node label add FIRSTNODENAME region=oneregion
kontena node label add FIRSTNODENAME region=secondregion
```

### Trigger CoreOS update manually
```
update_engine_client -check_for_update
journalctl -f
sudo reboot
```

### Remove multiple masters from the cloud
```
kontena cloud master ls | grep 588 | cut -f1 -d" " | xargs -L 1 kontena cloud master rm --force
```

### Let's Encrypt firewall

https traffic needs to be allowed from anywhere (https://community.letsencrypt.org/t/lets-encrypt-and-firewall-rules/18641)
