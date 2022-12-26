---
layout: post
title: "How to Analyze a Firewall Ruleset with Hadoop"
date: "2015-01-04"
categories: 
  - "automation"
tags: 
  - "analysis"
  - "firewall"
  - "hadoop"
  - "howto"
  - "log-analysis"
  - "ruleset"
---

**Note**: This is an old blog post and the code repository is not being actively maintained.

[Ruleset Analysis](https://github.com/arnesund/ruleset-analysis) is a tool for analyzing firewall log files to determine what firewall rules are in use and by what kind of traffic. The first release supports the Cisco ASA and FWSM firewalls. The analysis is built as Hadoop Streaming jobs since the log volume to analyze easily can reach hundreds of gigabytes or even terabytes for very active firewalls. To make useful results the logs analyzed must span a time period of at least a couple months, preferably six or twelve months. The analysis will tell you exactly what traffic was allowed by each of the firewall rules and when that traffic occurred.

A common use case for Ruleset Analysis is to use the insight produced to reduce the size of large firewall rulesets. Armed with knowledge about when a rule was last in use and by what traffic, it becomes easier to determine if the rule can be removed. Rules with no hits in the analyzed time span are also likely candidates for removal. In addition, Ruleset Analysis can be used to replace a generic rule with more specific rules. Traffic counters are often used to check what rules are in use, but I explained some of their shortcomings in [my previous post](http://arnesund.com/2015/01/01/reducing-the-size-of-large-firewall-rulesets/).

### How to install requirements

For instructions on how to install the prerequisites required for the analysis to work (mostly Python modules), see the [README](https://github.com/arnesund/ruleset-analysis/blob/master/README.md "Ruleset Analysis README") at Github.

### Sample results

Here is an example of the output for each firewall rule:
{% highlight shell %}
fw01: access-list inside-in, rule 123: permit tcp 10.1.0.0/24 -> 0.0.0.0/0:[8080]
access-list inside-in extended permit tcp object-group inside-subnets any object-group Web
Total number of hits: 7
 COUNT PROTO  FROM IP       TO IP          PORT  FIRST SEEN           LAST SEEN          
     6  TCP   10.1.0.156    20.30.40.124   8080  2014-06-06 14:47:35  2014-06-06 15:17:01
     1  TCP   10.1.0.98     100.200.31.82  8080  2014-09-27 08:15:34  2014-09-27 08:15:34
{% endhighlight %}

This says that outbound access to websites on port 8080 got seven hits during the last year, but only from two distinct sources. An internal machine initiated six of those connections to one external server on port 8080 in half an hour on June 6th. All in all, this tells us that the rule is rarely in use and may be a candidate for removal.

The second line of the output shows the access-list entry in the original Cisco syntax. Note that Ruleset Analysis supports object-groups and will expand the list of objects in the object-group to create distinct rules. For instance, here it has expanded the object-group Web to the TCP port 8080 (and other ports not shown here). For each object in an object-group the preprocessor creates a distinct rule object, effectively expanding the object-group to separate objects. The benefit of this is that Ruleset Analysis is able to find out which objects in an object-group are in use and which are not, so objects not in use can be removed from the object-group (and therefore from the ruleset).

### How to run the analysis on Hadoop

To be able to run the analysis you need the firewall config, log files and access to a Hadoop cluster.

Clone the repository from [Github](https://github.com/arnesund/ruleset-analysis "Ruleset Analysis on Github"):
{% highlight shell %}
git clone https://github.com/arnesund/ruleset-analysis.git
cd ruleset-analysis
{% endhighlight %}
Preprocess the config file to extract access-lists and generate ACL objects:
{% highlight shell %}
./preprosess_access_lists.py -f FW.CONF
{% endhighlight %}
Submit the job to the Hadoop cluster with the path to the firewall log files in the Hadoop filesystem HDFS (wildcards allowed):
{% highlight shell %}
./runAnalysis.sh /HDFS-PATH/TO/LOG/FILES
{% endhighlight %}
The output from Hadoop Streaming is shown on the console:
{% highlight shell %}
arnes@hadoop01:~/ruleset-analysis$ ./runAnalysis.sh /data/fw01/*2014*
arnes@hadoop01:~/ruleset-analysis$ packageJobJar: [.//config.py, .//firewallrule.py, .//input/accesslists.db, .//name-number-mappings.db, .//mapper.py, .//connlist-reducer.py, /tmp/hadoop-arnes/hadoop-unjar8081511066204186990/] [] /tmp/streamjob7183564462078091113.jar tmpDir=null
15/01/04 11:24:56 WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
15/01/04 11:24:56 WARN snappy.LoadSnappy: Snappy native library not loaded
15/01/04 11:24:57 INFO mapred.FileInputFormat: Total input paths to process : 365
15/01/04 11:24:57 INFO streaming.StreamJob: getLocalDirs(): [/data/1/mapred/local, /data/2/mapred/local, /data/3/mapred/local]
15/01/04 11:24:57 INFO streaming.StreamJob: Running job: job_201411291614_1372
15/01/04 11:24:57 INFO streaming.StreamJob: To kill this job, run:
15/01/04 11:24:57 INFO streaming.StreamJob: /usr/libexec/../bin/hadoop job  -Dmapred.job.tracker=hadoop01:8021 -kill job_201411291614_1372
15/01/04 11:24:57 INFO streaming.StreamJob: Tracking URL: http://hadoop01:50030/jobdetails.jsp?jobid=job_201411291614_1372
15/01/04 11:24:58 INFO streaming.StreamJob:  map 0%  reduce 0%
15/01/04 11:25:07 INFO streaming.StreamJob:  map 1%  reduce 0%
15/01/04 11:25:08 INFO streaming.StreamJob:  map 13%  reduce 0%
15/01/04 11:25:09 INFO streaming.StreamJob:  map 16%  reduce 0%
15/01/04 11:25:11 INFO streaming.StreamJob:  map 24%  reduce 0%
...
15/01/04 11:26:39 INFO streaming.StreamJob:  map 98%  reduce 29%
15/01/04 11:26:41 INFO streaming.StreamJob:  map 99%  reduce 30%
15/01/04 11:26:42 INFO streaming.StreamJob:  map 100%  reduce 30%
15/01/04 11:26:47 INFO streaming.StreamJob:  map 100%  reduce 33%
15/01/04 11:26:49 INFO streaming.StreamJob:  map 100%  reduce 67%
15/01/04 11:26:50 INFO streaming.StreamJob:  map 100%  reduce 100%
15/01/04 11:26:52 INFO streaming.StreamJob: Job complete: job_201411291614_1372
15/01/04 11:26:52 INFO streaming.StreamJob: Output: output-20150104-1124_RulesetAnalysis
{% endhighlight %}
Note the name of the output directory on the last line of output, "output-20150104-1124_RulesetAnalysis" in this example. You'll use that to fetch the results from HDFS. Insert the name of the output directory in the variable below:
{% highlight shell %}
mkdir output; outputdir="OUTPUT_PATH_FROM_JOB_OUTPUT"
hadoop dfs -getmerge $outputdir output/$outputdir
{% endhighlight %}
With the job results now on disk, the last step is to run postprocessing to generate the final report and view it:
{% highlight shell %}
./postprocess_ruleset_analysis.py -f output/$outputdir > output/$outputdir-report.log
less output/$outputdir-report.log
{% endhighlight %}
### Manually test the analysis on a small log volume

For small log volumes and trial runs, the analysis can be run with no Hadoop cluster (no parallellization), like this:

Clone the repository from [Github](https://github.com/arnesund/ruleset-analysis "Ruleset Analysis on Github"), if you haven't already:
{% highlight shell %}
git clone https://github.com/arnesund/ruleset-analysis.git
cd ruleset-analysis
{% endhighlight %}
Preprocess the config file to extract access-lists and generate ACL objects:
{% highlight shell %}
./preprosess_access_lists.py -f FW.CONF
{% endhighlight %}
Pipe the firewall log through the Python mapper and reducer manually:
{% highlight shell %}
cat FW.LOG | ./mapper.py | sort | ./reducer.py > results
{% endhighlight %}
Postprocess the results to generate the final ruleset report and take a look at it:
{% highlight shell %}
./postprocess_ruleset_analysis.py -f results > final_report
less final_report
{% endhighlight %}
