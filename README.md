# kontena-compose

Primarily setups a remote host with SSH to run Kontena with docker-compose.

Tested with: Ubuntu 16.04
Providers tested: AWS, DigitalOcean, Azure, OVH, packet.net, but should work with any provider (as it's just SSH and docker-compose)


## Setup (remote)

Requires Ruby so `bundle install` first.

Make your host(s) accessible with SSH by having `.ssh/config` setup.

For example if you want to run locally on docker-machine:

```
Host myhost
  HostName myhost.providercloud.com
  User user
  IdentityFile ~/.ssh/my_identity
```

Verify that `ssh myhost` works without a password.

## Installing master

`bin/initialize` deploys files required (using `bin/deploy`) to the target machine and runs initialization of `master` or `node`

```
# To use the defaults (:latest Kontena etc)
bin/initialize myhost master

# .. or to specify a version:
bin/initialize myhost master --kontena_version 1.1.4

# .. or to create a certificate automagically with Let's Encrypt SSL:
bin/initialize myhost master \
  --kontena_version 1.1.4 \
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

# .. all settings
bin/setup_master --help
```

## Adding node(s)

```
# To use the defaults (connects to master running in ws://localhost (one machine will be both master and node))
bin/initialize mynodehost node

# .. or to specify settings
bin/initialize mynodehost node \
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
bin/destroy mynodehost node
```

To remove master AND the entry for the master in Kontena Cloud use:
```
bin/destroy myhost master
```

Optionally to completely clean everything (containers and images) from Docker:
```
bin/destroy myhost docker
```

### Updating

```
# ensure that you have the env locally
bin/cat_env myhostg master > kontena/master/env
# edit the version
bin/deploy myhostg master
bin/restart myhostg master
```

And the same for the node.


## Setup (local)

## Testing

- vagrant 1.9.2

`test/vagrant.sh all`

## PRO-TIPS

### local kontena

```ruby
bin/initialize localhost master --kontena_version 1.1.6 --master_http_port 9292 --master_https_port 9293
bin/setup_master http://localhost:9292 matti.paksula@iki.fi --master_name localhost --grid_name localhost --grid_token localhost
bin/initialize localhost node --kontena_version 1.1.6 --master_uri ws://localhost:9292 --grid_token localhost

```

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


### vagrant as a docker machine

```
# put vagrant/docker.service to /lib/systemd/system/docker.service
cat vagrant/docker.service | vagrant ssh -c "sudo tee /lib/systemd/system/docker.service"
vagrant ssh -c "sudo systemctl daemon-reload && sudo systemctl restart docker"
curl 192.168.81.10:2375/v1.24/version
# DOCKER_HOST=tcp://192.168.81.10:2375
```
