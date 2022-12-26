---
layout: post
title: "Reducing the Size of Large Firewall Rulesets"
date: "2015-01-01"
categories: 
  - "automation"
tags: 
  - "analysis"
  - "firewall"
  - "log-analysis"
  - "ruleset"
---

After operating a set of firewalls for some years, the rulesets have grown to thousands of rules, each fulfilling a specific application need or some user demand. Firewalls don't live forever, and the time came to replace the current firewall with a new, more powerful appliance from a different vendor. Changing vendors made migrating rules more difficult since the syntax was different. In addition, the conversion tool provided by the new vendor failed to utilize the powerful features of the new syntax. So it was decided to implement all the rules on the new firewall manually.

When faced with a big, manual task, my first question is _How can we simplify this?_ One way to reduce the workload is to reduce the scope of work. In this case reduce the number of firewall rules that must be re-implemented. However, it is not easy to determine if a rule can be removed. Traffic counters give some information, but are typically reset on reboots. Before you go ahead and remove a rule you want to be sure no-one relied on that rule for, say, the last six or maybe twelve months. Any firmware upgrade in the last year could make traffic counters less valuable.

Among all the rules with positive counters there are almost certainly also rules that are no longer in use. The counters do not tell you when each hit occured in the period since last reset. However, the firewall logs contain that information. Configured for full audit logging, a firewall will tell you the exact pattern of the traffic that traversed the firewall. So parsing that information can potentially reveal what rules are in use and when.

A common issue with firewall rulesets is the generic rules. Those are the rules which are added when the application need is unclear or a deadline is rapidly approaching. The generic rules allow more than they should, and removing them requires in-depth knowledge and certainty about what the rule should have looked like. One way to get that knowledge is to inspect the audit logs in detail. Parsing all log entries it is possible to say with certainty what traffic was allowed by which rule. Armed with a list of all traffic matching a generic rule, it's easier to replace that rule with specific rules or remove it entirely. How to parse logs to be able to do that is [the topic of my next post](http://arnesund.com/2015/01/04/how-to-analyze-a-firewall-ruleset-with-hadoop/).
