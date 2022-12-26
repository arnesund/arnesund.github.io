---
layout: post
title: "Getting Started with SocketPlane and Docker on OpenStack VMs"
date: "2015-03-06"
categories: 
  - "openstack"
tags: 
  - "docker"
  - "howto"
  - "openstack"
  - "overlay-networking"
  - "socketplane"
  - "vxlan"
---

With all the well-deserved attention [Docker](https://www.docker.com/) gets these days, the networking aspects of Docker become increasingly important. As many have pointed out already, Docker itself has somewhat limited networking options. Several projects exist to fix this; [SocketPlane](http://socketplane.io/), [Weave](https://github.com/zettio/weave), [Flannel](https://github.com/coreos/flannel) by CoreOS and [Kubernetes](http://kubernetes.io/) (which is an entire container orchestration solution). Docker recently [acquired SocketPlane](https://blog.docker.com/2015/03/socketplane-excited-to-be-joining-docker-to-collaborate-with-networking-ecosystem/) to become part of Docker itself, both to gain better native networking options and to get help building the networking APIs necessary for other network solutions to plug into Docker.

In this post, I'll show how to deploy and use SocketPlane on OpenStack VMs. This is based on the technology preview of SocketPlane [available on Github](https://github.com/socketplane/socketplane), which I'll deploy on Ubuntu 14.04 Trusty VMs.

## Launch the first VM and bootstrap the cluster

As SocketPlane is a cluster solution with automatic leader election, all nodes in the cluster are equal and run the same services. However, the first node has to be told to bootstrap the cluster. With at least one node running, new nodes automatically join the cluster when they start up.

To get the first node to download SocketPlane, install the software including all dependencies, and bootstrap the cluster, create a Cloud-init script like this:

{% highlight shell %}
cat > socketplane-first.sh <<EOF
#!/bin/bash
curl -sSL http://get.socketplane.io/ | sudo BOOTSTRAP=true sh
sudo socketplane cluster bind eth0
EOF
{% endhighlight %}

Start the first node and wait for the SocketPlane bootstrap to complete before starting more nodes (it takes a while, so grab a cup of coffee):

{% highlight shell %}
$ nova boot --flavor m1.medium --image "Ubuntu CI trusty 2014-09-22" --key-name arnes --user-data socketplane-first.sh --nic net-id=df7cc182-8794-4134-b700-1fb8f1fbf070 socketplane1
$ nova floating-ip-associate socketplane1 10.0.1.244
{% endhighlight %}

You have to customize the flavor, image, key-name, net-id and floating IP to suit your OpenStack environment before running these commands. I attach a floating IP to the node to be able to log into it and interact with SocketPlane. If you want to watch the progress of Cloud-init, you can now tail the output logs via SSH like this:

{% highlight shell %}
$ ssh ubuntu@10.0.1.244 "tail -f /var/log/cloud-init*"
Warning: Permanently added '10.0.1.244' (ECDSA) to the list of known hosts.
==> /var/log/cloud-init.log <==
Mar 4 18:20:16 socketplane1 [CLOUDINIT] util.py[DEBUG]: Writing to /var/lib/cloud/instances/4e158f82-c5d8-4629-b7dc-2c1fbbe5f9f2/sem/config_scripts_vendor - wb: [420] 20 bytes
Mar 4 18:20:16 socketplane1 [CLOUDINIT] helpers.py[DEBUG]: Running config-scripts-vendor using lock (<FileLock using file '/var/lib/cloud/instances/4e158f82-c5d8-4629-b7dc-2c1fbbe5f9f2/sem/config_scripts_vendor'>)
...
Mar 4 18:20:16 socketplane1 [CLOUDINIT] util.py[DEBUG]: Running command ['/var/lib/cloud/instance/scripts/part-001'] with allowed return codes [0] (shell=False, capture=False)

==> /var/log/cloud-init-output.log <==
511136ea3c5a: Pulling fs layer
511136ea3c5a: Download complete
8771fbfe935c: Pulling metadata
8771fbfe935c: Pulling fs layer
8771fbfe935c: Download complete
0e30e84e9513: Pulling metadata
...
{% endhighlight %}

As you can see from the output above, the SocketPlane setup script is busy fetching the Docker images for the dependencies of SocketPlane and the SocketPlane agent itself. When the bootstrapping is done, the output will look like this:

{% highlight shell %}
7c5e9d5231cf: Download complete
7c5e9d5231cf: Download complete
Status: Downloaded newer image for clusterhq/powerstrip:v0.0.1
Done!!!
Requesting SocketPlane to listen on eth0
Cloud-init v. 0.7.5 finished at Wed, 04 Mar 2015 18:25:54 +0000. Datasource DataSourceOpenStack [net,ver=2]. Up 348.19 seconds
{% endhighlight %}

The "Done!!!" line marks the end of the setup script downloaded from get.socketplane.io. The next line of output is from the "sudo socketplane cluster bind eth0" command I included in the Cloud-init script.

### Important note about SocketPlane on OpenStack VMs

If you just follow the deployment instructions for a [Non-Vagrant install / deploy](https://github.com/socketplane/socketplane#non-vagrant-install--deploy "SocketPlane Non-Vagrant install/deploy") in the SocketPlane README, you might run into an issue with the SocketPlane agent. The agent by default tries to autodetect the network interface to bind to, but that does not seem to work as expected when using OpenStack VMs. If you encounter this issue, the agent log will be full of messages like these:

{% highlight shell %}
$ sudo socketplane agent logs
INFO[0007] Identifying interface to bind ... Use --iface option for static binding
INFO[0015] Identifying interface to bind ... Use --iface option for static binding
INFO[0023] Identifying interface to bind ... Use --iface option for static binding
INFO[0031] Identifying interface to bind ... Use --iface option for static binding
INFO[0039] Identifying interface to bind ... Use --iface option for static binding
...
{% endhighlight %}

To resolve this issue you have to explicitly tell SocketPlane which network interface to use:

{% highlight shell %}
sudo socketplane cluster bind eth0
{% endhighlight %}

If you don't, the SocketPlane setup process will be stuck and never complete. This step is required on all nodes in the cluster, since they follow the same setup process.

## Check the SocketPlane agent logs

The "socketplane agent logs" CLI command is useful for checking the cluster state and to see what events have occured. After the initial setup process has finished, the output will look similar to this:

{% highlight shell %}
$ sudo socketplane agent logs
==> WARNING: Bootstrap mode enabled! Do not enable unless necessary
==> WARNING: It is highly recommended to set GOMAXPROCS higher than 1
==> Starting Consul agent...
2015/03/04 18:25:54 consul.watch: Watch (type: nodes) errored: Get http://127.0.0.1:8500/v1/catalog/nodes: dial tcp 127.0.0.1:8500: connection refused, retry in 5s
==> Starting Consul agent RPC...
==> Consul agent running!
 Node name: 'socketplane1'
 Datacenter: 'dc1'
 Server: true (bootstrap: true)
 Client Addr: 127.0.0.1 (HTTP: 8500, HTTPS: -1, DNS: 8600, RPC: 8400)
 Cluster Addr: 10.20.30.161 (LAN: 8301, WAN: 8302)
 Gossip encrypt: false, RPC-TLS: false, TLS-Incoming: false

==> Log data will now stream in as it occurs:

 2015/03/04 18:25:54 [INFO] serf: EventMemberJoin: socketplane1 10.20.30.161
 2015/03/04 18:25:54 [INFO] serf: EventMemberJoin: socketplane1.dc1 10.20.30.161
 2015/03/04 18:25:54 [INFO] raft: Node at 10.20.30.161:8300 [Follower] entering Follower state
 2015/03/04 18:25:54 [INFO] consul: adding server socketplane1 (Addr: 10.20.30.161:8300) (DC: dc1)
 2015/03/04 18:25:54 [INFO] consul: adding server socketplane1.dc1 (Addr: 10.20.30.161:8300) (DC: dc1)
 2015/03/04 18:25:54 [ERR] agent: failed to sync remote state: No cluster leader
INFO[0111] Identifying interface to bind ... Use --iface option for static binding
INFO[0111] Binding to eth0
2015/03/04 18:25:55 watchForExistingRegisteredUpdates : 0
2015/03/04 18:25:55 key :
==> WARNING: Bootstrap mode enabled! Do not enable unless necessary
==> WARNING: It is highly recommended to set GOMAXPROCS higher than 1
==> Starting Consul agent...
==> Error starting agent: Failed to start Consul server: Failed to start RPC layer: listen tcp 10.20.30.161:8300: bind: address already in use
 2015/03/04 18:25:55 [ERR] http: Request /v1/catalog/nodes, error: No cluster leader
2015/03/04 18:25:55 consul.watch: Watch (type: nodes) errored: Unexpected response code: 500 (No cluster leader), retry in 5s
 2015/03/04 18:25:55 [WARN] raft: Heartbeat timeout reached, starting election
 2015/03/04 18:25:55 [INFO] raft: Node at 10.20.30.161:8300 [Candidate] entering Candidate state
 2015/03/04 18:25:55 [INFO] raft: Election won. Tally: 1
 2015/03/04 18:25:55 [INFO] raft: Node at 10.20.30.161:8300 [Leader] entering Leader state
 2015/03/04 18:25:55 [INFO] consul: cluster leadership acquired
 2015/03/04 18:25:55 [INFO] consul: New leader elected: socketplane1
 2015/03/04 18:25:55 [INFO] raft: Disabling EnableSingleNode (bootstrap)
 2015/03/04 18:25:55 [INFO] consul: member 'socketplane1' joined, marking health alive
 2015/03/04 18:25:56 [INFO] agent: Synced service 'consul'
INFO[0114] New Node joined the cluster : 10.20.30.161
2015/03/04 18:25:59 Status of Get 404 Not Found 404 for http://localhost:8500/v1/kv/ipam/10.1.0.0/16
2015/03/04 18:25:59 Updating KV pair for http://localhost:8500/v1/kv/ipam/10.1.0.0/16?cas=0 10.1.0.0/16 0
2015/03/04 18:25:59 Status of Get 404 Not Found 404 for http://localhost:8500/v1/kv/network/default
2015/03/04 18:25:59 Updating KV pair for http://localhost:8500/v1/kv/network/default?cas=0 default {"id":"default","subnet":"10.1.0.0/16","gateway":"10.1.0.1","vlan":1} 0
2015/03/04 18:25:59 Status of Get 404 Not Found 404 for http://localhost:8500/v1/kv/vlan/vlan
2015/03/04 18:25:59 Updating KV pair for http://localhost:8500/v1/kv/vlan/vlan?cas=0 vlan 0
{% endhighlight %}

SocketPlane uses [Consul](https://www.consul.io) as a distributed key-value store for cluster configuration and cluster membership tracking. From the log output we can see that a Consul agent is started, the "socketplane1" host joins, a leader election is performed (which this single Consul agent obviously wins), and key-value pairs for the default subnet and network are created.

## A note on the SocketPlane overlay network model

The real power of the SocketPlane solution lies in the overlay networks it creates. The overlay network spans all SocketPlane nodes in the cluster. SocketPlane uses VXLAN tunnels to encapsulate container traffic between nodes, so that several Docker containers running on different nodes can belong to the same virtual network and get IP addresses in the same subnet. This resembles the way OpenStack itself can use VXLAN to encapsulate traffic for a virtual tenant network that spans several physical compute hosts in the same cluster. Using SocketPlane on an OpenStack cluster which uses VXLAN (or GRE) means we use two layers of encapsulation, which is something to keep in mind if MTU and fragmentation issues occur.

## Spin up more SocketPlane worker nodes

Of course we need some more nodes as workers in our SocketPlane cluster to make it a real cluster, so create another Cloud-init script for them to use:

{% highlight shell %}
cat > socketplane-node.sh <<EOF
#!/bin/bash
curl -sSL http://get.socketplane.io/ | sudo sh
sudo socketplane cluster bind eth0
EOF
{% endhighlight %}

This is almost identical to the first Cloud-init script, just without the BOOTSTRAP=true environment variable.

Spin up a couple more nodes:

{% highlight shell %}
$ nova boot --flavor m1.medium --image "Ubuntu CI trusty 2014-09-22" --key-name arnes --user-data socketplane-node.sh --nic net-id=df7cc182-8794-4134-b700-1fb8f1fbf070 socketplane2
$ nova boot --flavor m1.medium --image "Ubuntu CI trusty 2014-09-22" --key-name arnes --user-data socketplane-node.sh --nic net-id=df7cc182-8794-4134-b700-1fb8f1fbf070 socketplane3
{% endhighlight %}

Watch the agent log from the first node in realtime with the -f flag (just like with "tail") to validate that the nodes join the cluster as they are supposed to:

{% highlight shell %}
$ sudo socketplane agent logs -f
2015/03/04 19:10:42 New Bonjour Member : socketplane2, _docker._cluster, local, 10.20.30.162
INFO[6398] New Member Added : 10.20.30.162
 2015/03/04 19:10:42 [INFO] agent.rpc: Accepted client: 127.0.0.1:57766
 2015/03/04 19:10:42 [INFO] agent: (LAN) joining: [10.20.30.162]
 2015/03/04 19:10:42 [INFO] serf: EventMemberJoin: socketplane2 10.20.30.162
 2015/03/04 19:10:42 [INFO] agent: (LAN) joined: 1 Err: <nil>
 2015/03/04 19:10:42 [INFO] consul: member 'socketplane2' joined, marking health alive
Successfully joined cluster by contacting 1 nodes.
INFO[6398] New Node joined the cluster : 10.20.30.162

2015/03/04 19:10:54 New Bonjour Member : socketplane3, _docker._cluster, local, 10.20.30.163
INFO[6409] New Member Added : 10.20.30.163
 2015/03/04 19:10:54 [INFO] agent.rpc: Accepted client: 127.0.0.1:57769
 2015/03/04 19:10:54 [INFO] agent: (LAN) joining: [10.20.30.163]
 2015/03/04 19:10:54 [INFO] serf: EventMemberJoin: socketplane3 10.20.30.163
 2015/03/04 19:10:54 [INFO] agent: (LAN) joined: 1 Err: <nil>
 2015/03/04 19:10:54 [INFO] consul: member 'socketplane3' joined, marking health alive
Successfully joined cluster by contacting 1 nodes.
INFO[6409] New Node joined the cluster : 10.20.30.163
{% endhighlight %}

The nodes joined the cluster as expected, with no need to actually SSH into the VMs and run any CLI commands, since Cloud-init took care of the entire setup process. As you may have noted I didn't allocate any floating IP to the new worker VMs, since I don't need access to them directly. All the VMs run in the same OpenStack virtual tenant network and are able to communicate internally on that subnet (10.20.30.0/24 in my case).

## Create a virtual network and launch the first container

To test the new SocketPlane cluster, first create a new virtual network "net1" with an address range you choose yourself:

{% highlight shell %}
$ sudo socketplane network create net1 10.100.0.0/24
{
 "gateway": "10.100.0.1",
 "id": "net1",
 "subnet": "10.100.0.0/24",
 "vlan": 2
}
{% endhighlight %}

Now you should have two SocketPlane networks, the default and the new one you just created:

{% highlight shell %}
$ sudo socketplane network list
[
 {
 "gateway": "10.1.0.1",
 "id": "default",
 "subnet": "10.1.0.0/16",
 "vlan": 1
 },
 {
 "gateway": "10.100.0.1",
 "id": "net1",
 "subnet": "10.100.0.0/24",
 "vlan": 2
 }
]
{% endhighlight %}

Now, launch a container on the virtual "net1" network:

{% highlight shell %}
$ sudo socketplane run -n net1 -it ubuntu /bin/bash
Unable to find image 'ubuntu:latest' locally
fa4fd76b09ce: Pulling fs layer
1c8294cc5160: Pulling fs layer
...
2d24f826cb16: Download complete
Status: Downloaded newer image for ubuntu:latest
root@4e06413f421c:/#
{% endhighlight %}

The "-n net1" option tells SocketPlane what virtual network to use. The container is automatically assigned a free IP address from the IP address range you chose. I started an Ubuntu container running Bash as an example. You can start any Docker image you want, as all arguments after "-n net1" are passed directly to the "docker run" command which SocketPlane wraps.

The beauty of SocketPlane is that you don't have to do any port mapping or linking for containers to be able to communicate with other containers. They behave just like VMs launched on a virtual OpenStack network and have access to other containers on the same network, in addition to resources outside the cluster:

{% highlight shell %}
root@4e06413f421c:/# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default
...
8: ovsaa22ac2: <BROADCAST,UP,LOWER_UP> mtu 1440 qdisc noqueue state UNKNOWN group default
 link/ether 02:42:0a:64:00:02 brd ff:ff:ff:ff:ff:ff
 inet 10.100.0.2/24 scope global ovsaa22ac2
 valid_lft forever preferred_lft forever
 inet6 fe80::ace8:d3ff:fe4a:ecfc/64 scope link
 valid_lft forever preferred_lft forever

root@4e06413f421c:/# ping -c 1 10.100.0.1
PING 10.100.0.1 (10.100.0.1) 56(84) bytes of data.
64 bytes from 10.100.0.1: icmp_seq=1 ttl=64 time=0.043 ms

root@4e06413f421c:/# ping -c 1 arnesund.com
PING arnesund.com (192.0.78.24) 56(84) bytes of data.
64 bytes from 192.0.78.24: icmp_seq=1 ttl=51 time=29.7 ms
{% endhighlight %}

## Multiple containers on the same virtual network

Keep the previous window open to keep the container running and SSH to the first SocketPlane node again. Then launch another container on the same virtual network and ping the first container to verify connectivity:

{% highlight shell %}
$ sudo socketplane run -n net1 -it ubuntu /bin/bash
$ root@7c30071dbab4:/# ip addr | grep 10.100
 inet 10.100.0.3/24 scope global ovs658b61c
$ root@7c30071dbab4:/# ping 10.100.0.2
PING 10.100.0.2 (10.100.0.2) 56(84) bytes of data.
64 bytes from 10.100.0.2: icmp_seq=1 ttl=64 time=0.307 ms
64 bytes from 10.100.0.2: icmp_seq=2 ttl=64 time=0.057 ms
{% endhighlight %}

As expected, both containers see each other on the subnet they share and can communicate. However, both containers run on the first SocketPlane node in the cluster. To prove that this communication works also between different SocketPlane nodes, I'll SSH from the first to the second node and start a new container there. To SSH between nodes I'll use the private IP address of the second SocketPlane VM, since I didn't allocate a floating IP to it:

{% highlight shell %}
ubuntu@socketplane1:~$ ssh 10.20.30.162
ubuntu@socketplane2:~$ sudo socketplane run -n net1 -it ubuntu /bin/bash
Unable to find image 'ubuntu:latest' locally
fa4fd76b09ce: Pulling fs layer
...
2d24f826cb16: Download complete
Status: Downloaded newer image for ubuntu:latest
root@bfde7387e160:/#

root@bfde7387e160:/# ip addr | grep 10.100
 inet 10.100.0.4/24 scope global ovs06e4b44

root@bfde7387e160:/# ping -c 1 10.100.0.2
PING 10.100.0.2 (10.100.0.2) 56(84) bytes of data.
64 bytes from 10.100.0.2: icmp_seq=1 ttl=64 time=1.53 ms

root@bfde7387e160:/# ping -c 1 10.100.0.3
PING 10.100.0.3 (10.100.0.3) 56(84) bytes of data.
64 bytes from 10.100.0.3: icmp_seq=1 ttl=64 time=1.47 ms

root@bfde7387e160:/# ping -c 1 arnesund.com
PING arnesund.com (192.0.78.25) 56(84) bytes of data.
64 bytes from 192.0.78.25: icmp_seq=1 ttl=51 time=30.2 ms
{% endhighlight %}

No trouble there, the new container on a different OpenStack VM can reach the other containers and also communicate with the outside world.

This concludes the Getting Started-tutorial for SocketPlane on OpenStack VMs. Please bear in mind that this is based on a technology preview of SocketPlane, which is bound to change as SocketPlane and Docker become more integrated in the months to come. I'm sure the addition of SocketPlane to Docker will bring great benefits to the Docker community as a whole!
