---
layout: post
title: "Spark - How to fix "WARN TaskSchedulerImpl: Initial job has not accepted any resources""
date: "2015-08-19"
categories: 
  - "analytics"
tags: 
  - "apache-spark"
  - "debugging"
  - "openstack"
  - "resource-limits"
  - "security"
---

![Apache Spark and Firewalls](/assets/images/apache-spark-and-firewalls.png)

When [setting up Apache Spark on your own cluster](http://spark.apache.org/docs/latest/spark-standalone.html), in my case on OpenStack VMs, a common pitfall is the following error message:

{% highlight shell %}
WARN TaskSchedulerImpl: Initial job has not accepted any resources; check your cluster UI to ensure that workers are registered and have sufficient memory
{% endhighlight %}

This error can pop up in the log output of the interactive Python Spark shell or [Jupyter](https://jupyter.org/) (formerly IPython Notebook) after starting a PySpark session and trying to perform any kind of Spark action (like .count() or .take() on a RDD), rendering PySpark unusable.

As the error message suggests, I investigated resource shortages first. The Spark Master UI reported that my PySpark shell had allocated all the available CPU cores and a small portion of the available memory. I therefore lowered the number of CPU cores for each Spark application on the cluster, by adding the following line in spark-env.sh on the master node and restarting the master:

{% highlight shell %}
SPARK_MASTER_OPTS="-Dspark.deploy.defaultCores=4"
{% endhighlight %}

After this change my PySpark shell was limited to 4 CPU cores of the 16 CPU cores in my cluster at that time, instead of reserving all available cores (the default setting). However, even though the Spark UI now reported there would be enough free CPU cores and memory to actually run some Spark actions, the error message still popped up and no Spark actions would execute.

While debugging this issue, I came across a [Spark-user mailing list post](http://mail-archives.us.apache.org/mod_mbox/spark-user/201408.mbox/%3CCAAOnQ7uv6EHHmFO41aBaEhFYUtW6iepf7111+Kq+ARTRoSyyHA@mail.gmail.com%3E) by Marcelo Vanzin of Cloudera where he outlines two possible causes for this particular error:

> "...
> - You're requesting more resources than the master has available, so
> your executors are not starting. Given your explanation this doesn't
> seem to be the case.
> 
> - The executors are starting, but are having problems connecting 
> back to the driver. In this case, you should be able to see 
> errors in each executor's log file.
> ..."

The second of these was causing this error in my case. The host firewall on the host where I ran my PySpark shell rejected the connection attempts back from the worker nodes. After allowing all traffic between all nodes involved, the problem was resolved! The driver host was another VM in the same OpenStack project, so allowing all traffic between the VMs in the same project was OK to do security-wise.

The error message is not particularly useful in the case where executors are unable to connect back to the driver. If you encounter the same error message, remember to check firewall logs from all involved firewalls (host and/or network firewalls).

On a side note, this requirement of Spark to connect back from executors to the driver makes it harder to set up a Spark cluster in a secure way. Unless the driver is in the same security zone as the Spark cluster, it may not be possible to allow the Spark cluster workers to establish connections to the driver host on arbitrary ports. Hopefully the Apache Spark project will address this limitation in a future release, by making sure all necessary connections are established by the driver (client host) only.

~ Arne ~
