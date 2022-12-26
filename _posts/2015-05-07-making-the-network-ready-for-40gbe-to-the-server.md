---
layout: post
title: "Making the Network Ready for 40GbE to the Server"
date: "2015-05-07"
categories: 
  - "network-design"
tags: 
  - "40gbe"
  - "breakout-cables"
  - "dac-cables"
  - "leaf-spine"
  - "qsfp"
  - "top-of-rack"
---

In today's server networks, 10GbE has become commonplace and has taken over for multiple 1GbE links to each server. However, for some workloads, 10GbE might not be enough. One such case is OpenStack network nodes which potentially handle a big part of the traffic in and out of an OpenStack cloud (depending on how it's configured). When faced with such use cases, how should the network prepare for delivering 40GbE\* to servers?

The issue here is the number of available 40GbE ports on data center switches and the cost of cabling. The most cost-effective cabling for both 10GbE and 40GbE is the [Direct Attached Cable](http://en.wikipedia.org/wiki/Twinaxial_cabling "Twinaxial cabling") (DAC) type based on Twinaxial cabling. Such cables are based on copper and have transceivers directly connected to each end of the cable. For 10GbE the SFP+ standard is commonplace in server NICs and switches. 40GbE uses the slightly larger QSFP transceivers, which internally are made up of four 10Gbit/s lanes (an important feature which we'll come back to). DAC cables exist in lengths up 10 metres (33 feet), but the price increases substantially when the cables get longer than 3 to 5 metres. When longer runs of 10GbE or 40GbE than 10 metres are needed, fiber cabling and separate transceivers are the only option. The cost of each transceiver is usually several times that of one DAC cable. Constraints like that are important to take into account when designing a data center network.

In an end-of-row design with chassis-based switches it's relatively easy to provide the needed 40GbE ports by adding line cards with the right port type, but the cabling cost will be an issue. Servers in adjacent racks may use DAC cabling, but as the distance to each server NIC increases so does the cost of each DAC cable. In addition, fiber connections have to be used for everything longer than 10 metres, which is further adding to the cabling costs.

On the contrary, with a top-of-rack switch design where all the cabling is inside each rack, the cable lengths are limited to 3 metres at the most. That makes DAC cables a perfect fit. However, the issue then becomes how to make 40GbE ports available to servers from top-of-rack switches. Typical 10GbE datacenter switches are equipped with some 40GbE ports for uplinks to the rest of the network (commonly a spine layer in bigger designs), so it may be tempting to use some of those for the few servers requiring 40GbE in the beginning. Doing so is not advisable, since it decreases the available uplink bandwidth and limits the scalability of the design. With a leaf-spine design with four spine switches the requirement is four uplinks from each leaf. When bandwidth usage increases, you may want to increase that by either increasing the number of spines to eight or double the amount of bandwidth from each leaf to each spine. Both of these scalability options require eight 40GbE ports for spine uplinks, so if you've used some of those 40GbE ports to connect servers, you don't have the necessary ports to scale.

If 10GbE switches are not an option in a mixed 10/40GbE environment where only a handful of servers need 40GbE, then what about pure 40GbE top-of-rack switches? Several vendors supply 1 RU 40GbE data center switches with 24 to 32 QSFP ports. With a majority of servers still using 10GbE, this might not seem like a viable option. Enter the DAC Breakout Cable. Using a QSFP-to-SFP+ breakout cable, each 40GbE port can be split into four individual 10GbE ports and used to connect several servers to the switch. What makes this possible is the mentioned 4 x 10Gbit/s lanes that 40GbE QSFP is made up of internally.

Using breakout cables for all server cabling in a rack enables a smooth migration path to 40GbE, since the servers that need 40GbE can get their own QSFP port on the switch. In a leaf-spine design with four spines, even a 24-port 40GbE top-of-rack switch is a viable leaf option. Using 4 ports for spine uplinks there is 20 ports available for servers, which equals a total of 80 10GbE connections using breakout cables. That's enough for 40 servers with dual 10GbE. When a few servers migrate to 40GbE NICs, you re-cable them using QSFP DAC cables to the top-of-rack switch. If you need to scale out to eight spines, you take four more 40GbE ports for spine uplinks and adjust down the number of possible server 10GbE links accordingly. This design provides flexibility both in terms of spine uplink count and gradual 10-to-40GbE migration for servers. An then, in the near future when a majority of servers use 40GbE, you can add another leaf switch to increase the available port count (or replace the one in the rack with a model with higher port count).

**~** Arne **~**

\* I'm aware of the 25/50 GbE initiative and it will be very interesting to see which of the 40GbE and 25 GbE technologies that will prevail in the future. 25 GbE might pan out as the most cost-efficient alternative. However, the 40GbE technology is already used in today's networks as the preferred spine uplink technology, which makes it relatively easy to create a migration path to 40GbE for servers too.
