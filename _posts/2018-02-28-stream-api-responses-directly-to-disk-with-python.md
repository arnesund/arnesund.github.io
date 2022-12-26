---
layout: post
title: "Stream API responses directly to disk with Python"
date: "2018-02-28"
tags: 
  - "data-science"
  - "gzip"
  - "json"
  - "python"
  - "requests"
  - "streaming"
  - "tools"
---

Python is the de-facto language for Data Science work. It's very convenient to rapidly prototype a solution in Python and see if it works. However when faced with setting up the same solution in production, there are new space and time constraints to take into account. You'll likely find that memory usage is the number one resource constraint you need to pay attention to. So let me share a useful trick to reduce memory usage in the early stages of a Python job.

To get your hands on training data, a very common step is to call an API and get data back in JSON format. For example for [fetching tweets from Twitter](https://developer.twitter.com/en/docs/tweets/search/api-reference/get-search-tweets.html). The simplest approach when using Python is to send an API call using [Requests](http://docs.python-requests.org/en/master/), store the response in a variable, decode the JSON and save it to disk for later processing.

This works well for small datasets, but when you try this on bigger JSON-based datasets, it results in very high memory usage. The problem is that you buffer data in memory and decode it, before saving to disk. Luckily, there is a better way.

## Streaming API responses directly to disk

The Requests library has [support for streaming](http://docs.python-requests.org/en/master/user/advanced/#streaming-requests). This enables you to iterate over the results you get _as they arrive_, instead of waiting for the entire response and buffering it in memory. Here's a code snippet showing how this can be done:

{% highlight python %}
with requests.post(path, data=ojb, headers=headers, stream=True) as response:
  response.raise_for_status()
  with gzip.open('out.gz', mode='wt', encoding='utf-8') as f:
    for chunk in response.iter_content(10240, decode_unicode=True):
      f.write(chunk)
{% endhighlight %}

With this code pattern the JSON is saved directly to disk in a compressed format as soon as it arrives over the network. The iterator ensures that you process chunks of 10240 bytes at a time, meaning that this is the maximum number of bytes your Python job has in memory at any time. The number of bytes is something you can tune and experiment with to figure out what works best in each case.

The impact of streaming response directly to disk is potentially huge. I've seen reductions in memory usage from tens of GB to almost nothing for jobs that migrated to this optimized approach.

One caveat of this approach is that it becomes a bit harder to extract parts of the JSON response if you need to do so. One example is APIs that use pagination, where the start and stop markers are part of the JSON response. A way to handle this is to resort to a simple text search of each chunk before the write call. This can work if what you're trying to find fits nicely into one chunk. For instance if the very last chunk contains the necessary pagination values.

I believe this optimisation is important to use whenever possible, even if JSON parsing becomes a bit harder. It's a good way to control the memory usage of a Python job that is fetching big datasets from an API. Using this approach the job should be able to stay within the memory constraints in production while fetching data.
