---
layout: post
title: "Analyzing Popular Topics In My Twitter Timeline using Apache Spark"
date: "2015-07-13"
categories: 
  - "analytics"
tags: 
  - "apache-spark"
  - "distributed-analysis"
  - "mapreduce"
  - "mongodb"
  - "topic-analysis"
  - "twitter-api"
---

| ![Word cloud of Twitter hashtags](/assets/images/most_popular_twitter_topics.png) | 
| Most popular Twitter topics, generated using Apache Spark and [Wordle.net](http://www.wordle.net/create) |

Over the last weeks I've dived into data analysis using [Apache Spark](https://spark.apache.org/). Spark is a framework for efficient, distributed analysis of data, built on the Hadoop platform but with much more flexibility than classic Hadoop MapReduce. To showcase some of the functionality I'll walk you through an analysis of Twitter data. The code is available as [an IPython Notebook on Github](https://github.com/arnesund/tw-hashtags/blob/master/Twitter_Hashtag_Analysis.ipynb).

The question I want to answer using Spark is: _What topics are people currently tweeting about?_ The people are in this case the ones I follow on Twitter, at the moment approx. 600 Twitter users. They represent a diverse set of interests mirroring the topics I'm interested in, such as data analysis, machine learning, networking technology, infrastructure, motor sports and so on. By extracting the hashtags they've used in tweets the last week and do a standard word count I'll generate a list of the most popular topics right now.

The amount of functionality for data analysis in Spark is impressive. Spark features [a long list](https://spark.apache.org/docs/latest/api/python/pyspark.html#pyspark.RDD) of available transformations and actions, such as map, filter, reduce, several types of joins, cogroup, sum, union, intersect and so on. In addition, Spark has a machine learning library with a growing number of [models and algorithms](https://spark.apache.org/docs/latest/mllib-guide.html). For instance does Spark MLlib include everything needed to do the Linear Regression example I did on AWS in my [previous blog post](http://arnesund.com/2015/05/31/using-amazon-machine-learning-to-predict-the-weather/). Spark also comes with a Streaming component where batch analysis pipelines easily can be set up to run as realtime analysis jobs instead. Compared to classic Hadoop MapReduce Spark is not only more flexible, but also much faster thanks to the in-memory based analysis.

To do the Twitter analysis, I first fetched about 24000 tweets from the Twitter API using a Python module called [Tweepy](http://www.tweepy.org/):

{% gist 50bd6418d4036621dfd3 %}

Each tweet was saved to a local MongoDB instance for persistence. The loop first checks the database to see if that user has been processed already, to save time if the loop has to be run several times. Due to [rate limiting of the Twitter API](https://dev.twitter.com/rest/public/rate-limits) it took about 2 hours to download the dataset. By the way, the term "friends" is the word Twitter uses to reference the list of users that a user follows.

The code snippet above depends on a valid, authorized API session with the Twitter API and an established connection to MongoDB. See the [IPython Notebook](https://github.com/arnesund/tw-hashtags/blob/master/Twitter_Hashtag_Analysis.ipynb) for the necessary code to establish those connections. Of the dependencies the Python modules "tweepy" and "pymongo" need to be installed, preferably using pip to get the latest versions.

With the tweets saved in MongoDB, we are ready to start doing some filtering and analysis on them. First, the set of tweets need to be loaded into Spark and filtered:

{% gist 2b671d945c73fe655eaa %}

In the code snippet above I use _sc.parallelize()_ to load a Python list into Spark, but I could just as easily have used _sc.textfile()_ to load data from a file on disk or _sc.newAPIHadoopFile()_ to load a file from HDFS. Spark also supports use of Hadoop connectors to load data directly from other systems [such as MongoDB](https://github.com/mongodb/mongo-hadoop/wiki/Spark-Usage), but that connector unfortunately does not support PySpark yet. In this case the dataset fits in memory of the Python process so I can use sc.parallelize() to load it into Spark, but if I'd like to run the analysis on a longer timespan than one week that would not be feasible. To see how the MongoDB connector can be used with Python, check out [this example code](https://github.com/dhesse/SparkTalk/blob/master/mongodb-demo/mongodb-demo.py) by [@notdirkhesse](https://twitter.com/notdirkhesse) which he demonstrated as part of his excellent [Spark talk](http://dhesse.github.io/SparkTalk/#/) in June.

"sc" is the SparkContext object, which is the object used to communicate with the Spark API from Python. I'm using a [Vagrant box with Spark set up](https://github.com/spark-mooc/mooc-setup) and "sc" initialized automatically, which was provided as part of the very interesting Spark MOOCs CS100 and CS190 (BerkeleyX Big Data X-Series). The SparkContext can be initialized to use remote clusters running on EC2 or Databricks instead of a local Vagrant box, which is how you'd scale out the computations.

Spark has a concept of RDDs, Resilient Distributed Datasets. RDDs represent an entire dataset regardless of how it is distributed around on the cluster of nodes. RDDs are immutable, so a transformation on a RDD returns a new RDD with the results. The last two lines of the code snippet above are transformations to filter() the dataset. An important point to note about Spark is that all transformations are lazily evaluated, meaning they are not computed until an action is called on the resulting RDD. The two filter statements are only recorded by Spark so that it knows how to generate the resulting RDDs when needed.

Let's inspect the filters in a bit more detail:

{% highlight python %}
tweetsWithTagsRDD = allTweetsRDD.filter(lambda t: len(t['entities']['hashtags']) > 0)
{% endhighlight %}

The first filter transformation is called on allTweetsRDD, which is the RDD that represents the entire dataset of tweets. For each of the tweets in allTweetsRDD, the lambda expression is evaluated. Only those tweets where the expression equals True is returned to be included in tweetsWithTagsRDD. All other tweets are silently discarded.

{% highlight python %}
filteredTweetsRDD = tweetsWithTagsRDD.filter(lambda t: time.mktime(parser.parse(t['created_at']).timetuple()) > limit_unixtime)
{% endhighlight %}

The second filter transformation is a bit more complex due to the datetime calculations, but follows the same pattern as the first. It is called on tweetsWithTagsRDD, the results of the first transformation, and checks if the tweet timestamp in the "created\_at" field is recent enough to be within the time window I defined (one week). The tweet timestamp is parsed using python-dateutil, converted to unixtime and compared to the precomputed limit.

For those of you who are already acquainted with Spark, the following syntax might make more sense:

{% highlight python %}
filteredTweetsRDD = (allTweetsRDD
                     .filter(lambda t: len(t['entities']['hashtags']) > 0)
                     .filter(lambda t: time.mktime(parser.parse(t['created_at']).timetuple()) > limit_unixtime)                    )
{% endhighlight %}

The inspiration from [Functional Programming](https://en.wikipedia.org/wiki/Functional_programming) in Sparks programming model is apparent here, with enclosing parentheses around the entire statement in addition to the use of lambda functions. The resulting filteredTweetsRDD is the same as before. However, by assigning a variable name to the results of each filter transformation, it's easy to compute counts:

{% highlight python %}
tweetCount = allTweetsRDD.count()
withTagsCount = tweetsWithTagsRDD.count()
filteredCount = filteredTweetsRDD.count()
{% endhighlight %}

count() is an example of an action in Spark, so when I execute these statements the filter transformations above are also computed. The counts revealed the following about my dataset:

- Total number of tweets: 24271
- Tweets filtered away due to no hashtags: 17150
- Of the tweets who had hashtags, 4665 where too old
- Resulting set of tweets to analyze: 2456

Now we're ready to do the data analysis part! With a filtered set of 2456 tweets in filteredTweetsRDD, I proceed to extract all hashtags and do a word count to find the most popular tags:

{% gist fa25f4f98bdcab314d53 %}

What's happening here is that I'm creating a new Pair RDD consisting of tuples of _(hashtag, count)_. The first step is to extract all hashtags with a flatMap(), and remember that every tweet can contain a list of multiple tags.

{% highlight python %}
filteredTweetsRDD.flatMap(lambda tweet: [ hashtag['text'].lower() for hashtag in tweet['entities']['hashtags'] ])
{% endhighlight %}

A flatMap() transformation is similar to a map(), which passes each element of a RDD through a user-supplied function. In contrast to map, flatMap ensures that the result is a list instead of a nested datastructure - like a list of lists for instance. Since the analysis I'm doing doesn't care which tweet has which hashtags, a simple list is sufficient. The lambda function does a list comprehension to extract the "text" field of each hashtag in the data structure and lowercase it. The data structure for tweets looks like this:

{% highlight json %}
{
 u'contributors': None,
 u'coordinates': None,
 u'created_at': u'Sun Jul 12 19:29:09 +0000 2015',
 u'entities': {u'hashtags': [{u'indices': [75, 83],
                              u'text': u'TurnAMC'},
                             {u'indices': [139, 140],
                              u'text': u'RenewTURN'}],
               u'symbols': [],
               u'urls': [],
...
{% endhighlight %}

So the result of the lambda function on this tweet would be:

{% highlight json %}
['turnamc', 'renewturn']
{% endhighlight %}

After the flatmap(), a standard word count using map() and reduceByKey() follows:

{% highlight python %}
.map(lambda tag: (tag, 1))
.reduceByKey(lambda a, b: a + b)
{% endhighlight %}

A word count is the "Hello World"-equivalent for Spark. First, each hashtag is transformed to a key-value tuple of _(hashtag, 1)_. Second, all tuples with the same key are reduced using the lambda function, which takes two counts and returns the sum. Spark runs both map() and reduceByKey() in parallel on the data partition residing on each worker node in a cluster, before the results of the local reduceByKey() are shuffled so that all values belonging to a key is processed by one worker. This behaviour mimics the use of a Combiner in classic Hadoop MapReduce. Since both map() and reduceByKey() are transformations, the result is a new RDD.

To actually perform the computations and get results, I call the action takeOrdered() with a cursom sort function to get the top 20 hashtags by count. The sort function simply orders key-value pairs descending by value.

The 20 most used hashtags in my dataset turned out to be:

{% highlight json %}
[(u'bigdata', 114),
 (u'openstack', 92),
 (u'gophercon', 71),
 (u'machinelearning', 68),
 (u'sdn', 66),
 (u'datascience', 58),
 (u'docker', 56),
 (u'dtm', 46),
 (u'audisport', 44),
 (u'dtmzandvoort', 42),
 (u'hpc', 40),
 (u'welcomechallenges', 38),
 (u'devops', 37),
 (u'analytics', 36),
 (u'awssummit', 36),
 (u'infosec', 33),
 (u'security', 32),
 (u'openstacknow', 29),
 (u'renewturn', 29),
 (u'mobil1scgp', 28)]
{% endhighlight %}

In this list it's easy to recognize several of the interests I mentioned earlier. Big Data is the top hashtag, which together with Machine Learning and Data Science make up a significant portion of the interesting tweets I see in my Twitter timeline. OpenStack is another top hashtag, which is a natural topic given my current job in infrastructure. SDN is a closely related topic and an integrated part of the OpenStack scene. Docker is taking over in the infrastructure world and the DevOps mindset that follows with it is also a popular topic.

What's interesting to see is that conferences spark a lot of engagement on Twitter. Both [GopherCon](http://www.gophercon.com/) and [AWS Summit](http://aws.amazon.com/summits/) turn up in the top 20 list since they took place during the week of tweets I analyzed. The same goes for motor sports (hashtags [DTM Zandvoort](http://www.dtm.com/en/event/2015-zandvoort), Audi Sport, Welcome Challenges), although in that case it's the professional teams, in contrast to conference goers, that make sure their Twitter followers are constantly updated on standings and news.

As I'm sure you've noticed, the word cloud at the beginning of this blog post is generated from the list of hashtags in the dataset and their counts. To finish off the analysis I also computed the average number of hashtags per tweet that had at least one hashtag:

{% highlight python %}
# Count the number of hashtags used
totalHashtags = countsRDD.map(lambda (key, value): value) \\
                         .reduce(lambda a, b: a + b)

# Compute average number of hashtags per tweet
print('A total of {} hashtags gives an average number of ' +
      'tags per tweet at {}.'.format(totalHashtags, 
      round(totalHashtags/float(filteredTweetsRDD.count()), 2)))
{% endhighlight %}

Here I do another map + reduce, but this time the map function extracts the count for each hashtag and the reduce function sums it all up. It is very easy to build such pipelines of transformations to get the desired results. The speed and flexibility of Spark lowers the entry point and invites the user to do more such computations. In closing, here are the numbers:

- A total of 4030 hashtags analyzed
- An average number of tags per tweet at 1.64

~ Arne ~
