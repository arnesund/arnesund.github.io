---
layout: post
title: "New Skill Sets Needed for Network Specialists"
date: "2015-01-11"
categories: 
  - "automation"
tags: 
  - "apis"
  - "automation"
  - "firewalls"
  - "mirrorlist-update"
  - "python"
  - "rulesets"
  - "scripting"
---

I share a lot of the views presented by [@netmanchris](https://twitter.com/netmanchris "@netmanchris") in his [plan for technology areas to focus on](http://kontrolissues.net/2015/01/08/plans-for-2015-where-to-from-here/) and the follow-up post [It Generalist or Network Specialist?](http://kontrolissues.net/2015/01/09/it-generalist-or-network-specialist/). I started out in this field as a Networking Specialist focusing on the traditional areas like switching, routing and firewalls. However, over time the need for automation, scripting and data analysis popped up more and more in my day job, to be able to automate manual tasks and improve the quality of networking services like firewall rulesets.

I've written about a use case for data analysis in networking [in a previous post](http://arnesund.com/2015/01/04/how-to-analyze-a-firewall-ruleset-with-hadoop/ "How to Analyze a Firewall Ruleset with Hadoop"). Another example I want to highlight is the need for automatically updating firewall object-groups with new IP addresses as DNS entries for remote services change. Not all firewalls support DNS names as destination in a firewall rule. When a server need access to a specific remote site, and that site changes IP addresses from time to time, the IP adresses in the firewall config need to change too. To facilitate this I implemented a solution using Python which keeps object-groups in the firewall config in sync with IP addresses in DNS replies.

So far, these examples are from the traditional networking field. There is a new kind of Networking in the making with the invention of SDN solutions and the pervasive virtualization of everything, not just servers. Almost everything in this new Networking has APIs to support automation and requires us to learn some programming to be able to implement efficient solutions.

Python has emerged as the language of choice to sysadmins and net admins. To be able to use Python efficiently, basic knowledge of relevant modules is key. For example [Paramiko](http://www.paramiko.org/ "Paramiko") for using SSH in scripts and [IPy](https://pypi.python.org/pypi/IPy/ "IPy") to handle IP addresses and subnets easily. To interface with APIs there may be specific modules available like [python-neutronclient](http://docs.openstack.org/developer/python-neutronclient/ "Python bindings to the OpenStack Network API") for the OpenStack Neutron API, if not you can always use HTTP via [Requests](http://docs.python-requests.org/en/latest/ "Requests: HTTP for Humans").

In addition to Python I see knowledge of Git, Chef/Puppet, hypervisors, Linux networking, OVS, OpenStack and so on as very important in this new infrastructure-as-code movement. The new networking engineer role will be a hybrid sysadmin/netadmin/devop role and brings with it opportunities to make every day at work even more interesting!

~ Arne ~
