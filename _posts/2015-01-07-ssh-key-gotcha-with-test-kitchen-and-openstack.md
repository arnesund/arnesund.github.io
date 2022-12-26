---
layout: post
title: "SSH Key Gotcha with Test Kitchen and OpenStack"
date: "2015-01-07"
categories: 
  - "automation"
tags: 
  - "chef"
  - "kitchen"
  - "openstack"
  - "ssh"
---

When setting up Kitchen to use [OpenStack as the provider](https://github.com/test-kitchen/kitchen-openstack "Kitchen-OpenStack plugin at Github") instead of Vagrant, I encountered a puzzling authentication issue on creation of the instance. I had my public and private SSH key in ~/.ssh/ and they matched the SSH key stored in OpenStack and referenced in the Kitchen configuration. The creation of instances failed with the following error:

{% highlight shell %}
$ kitchen create
-----> Starting Kitchen (v1.2.1)
-----> Creating <default-ubuntu-1404>...
 OpenStack instance <88ef6616-04d3-4d0c-a631-8bb0d91a4c63> created.
....................
(server ready)
 Attaching floating IP from <public> pool
 Attaching floating IP <10.0.1.216>
 Waiting for 10.0.1.216:22...
 Waiting for 10.0.1.216:22...
 Waiting for 10.0.1.216:22...
 (ssh ready)
 Using OpenStack keypair <arnes>
 Using public SSH key <~/.ssh/id_rsa.pub>
 Using private SSH key <~/.ssh/id_rsa>
 Adding OpenStack hint for ohai
net.ssh.transport.server_version[3fd08462809c]
net.ssh.transport.algorithms[3fd0846382bc]
net.ssh.authentication.key_manager[3fd08466a064]
net.ssh.authentication.session[3fd08466a8d4]
>>>>>> ------Exception-------
>>>>>> Class: Kitchen::ActionFailed
>>>>>> Message: Failed to complete #create action: [Authentication failed for user ubuntu@10.0.1.216]
>>>>>> ----------------------
>>>>>> Please see .kitchen/logs/kitchen.log for more details
>>>>>> Also try running `kitchen diagnose --all` for configuration
{% endhighlight %}

After some debugging and research my focus turned to the contents of the SSH key files. When generating my keys I originally used PuTTYGen on Windows and saved them in OpenSSH format in addition to PuTTY format. It was the OpenSSH-files I had copied to ~/.ssh/. The format of the public key file was:

{% highlight shell %}
---- BEGIN SSH2 PUBLIC KEY ----
Comment: <Comment>
<SSH-key-string>
---- END SSH2 PUBLIC KEY ----
{% endhighlight %}

I am most used to the one-line format for public keys used in the authorized_keys file, so I changed the contents of the key file to match the following format:

{% highlight shell %}
ssh-rsa <SSH-key-string> <Comment>
{% endhighlight %}

Luckily, that was enough for Test Kitchen to work as intended:

{% highlight shell %}
$ kitchen create
-----> Starting Kitchen (v1.2.1)
-----> Creating <default-ubuntu-1404>...
 OpenStack instance <c08688f6-a754-4f43-a365-898a38fc06f8> created.
.........................
(server ready)
 Attaching floating IP from <public> pool
 Attaching floating IP <10.0.1.243>
 Waiting for 10.0.1.243:22...
 Waiting for 10.0.1.243:22...
 Waiting for 10.0.1.243:22...
 (ssh ready)
 Using OpenStack keypair <arnes>
 Using public SSH key <~/.ssh/id_rsa.pub>
 Using private SSH key <~/.ssh/id_rsa>
 Adding OpenStack hint for ohai
net.ssh.transport.server_version[3fe8926c1320]
net.ssh.transport.algorithms[3fe8926c06b4]
net.ssh.connection.session[3fe89270b420]
net.ssh.connection.channel[3fe89270b2cc]
Finished creating <default-ubuntu-1404> (0m50.68s).
-----> Kitchen is finished. (0m52.22s)
{% endhighlight %}
