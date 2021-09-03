---
title: How to set up a per-request log level filter
layout: post
date: 2020-01-20
location: Sydney, Australia
description: |
  This blog shows how to let clients control the log level of the backend app through the HTTP request header.
comments: true
og_image: /images/hario-filters-in-action.jpg
---

The ability to easily change the log level of an application from INFO to DEBUG, or any other log level, is a feature frequently desired to have in any backend system. What if there is a way to configure the application to dynamically set its log level based on an input given by the consumer of the application. More specifically, this blog post will demonstrate how to tune Java's **[Logback](http://logback.qos.ch/){:target="_blank"}** and **[Log4j](http://logging.apache.org/log4j/2.x/){:target="_blank"}** libraries to let HTTP clients define what log level to generate on the the server-side by simply passing an HTTP header.

<!--more-->

In a nutshell, a request like this:

{% highlight bash %}
curl -H "X-Log-Level: DEBUG" http://localhost:8000/hello
{% endhighlight %}

Would result in logs **set to the DEBUG level**, only for that request, in the *hello* service logs.
<br><br>

<figure class="image">
<amp-img
    src="{{ site.cdn.https }}/images/hario-filters-in-action.jpg"
    alt="filters-in-action"
    class="image-center"
    height="1"
    width="1"
    layout="responsive">
</amp-img>
<figcaption class="image-center-caption">Image: Filters in action.</figcaption>
</figure>

Advantages:

* Easy troubleshooting in production.
* No need to restart the service.
* Delegate control to the client.

**Time for action.** Getting this to work is mostly a matter of configuring properly the logger framework.

Both Java logging frameworks Logback and Log4j have a capability called **[Filters](http://logback.qos.ch/manual/filters.html){:target="_blank"}**. They allow log events to be evaluated to determine if or how they should be published. A developer can write a custom implementation of a Filter, however many implementations are already provided. One of them is the **[DynamicThresholdFilter](http://logback.qos.ch/apidocs/ch/qos/logback/classic/turbo/DynamicThresholdFilter.html){:target="_blank"}**.

The DynamicThresholdFilter allows filtering by log level based on specific attributes which are present in the MDC.

The **[MDC](http://logback.qos.ch/manual/mdc.html){:target="_blank"}** (Mapped Diagnosed Context) is a key piece here because it needs to be used to signal which log level to use in the thread context initiated by the HTTP request.

Assigning a value to the MDC is simple and can be done with SLF4J:

{% highlight xml %}
org.slf4j.MDC.put("X-Log-Level", "DEBUG");
{% endhighlight %}

The idea is to set the log level in the MDC right after the request comes in, using a Servlet Request Filter, for example.

### Logback configuration

The DynamicThresholdFilter in Logback is quite powerful, but a bit more difficult to distil.

A thoroughly [reading of the official docs](http://logback.qos.ch/apidocs/ch/qos/logback/classic/turbo/DynamicThresholdFilter.html){:target="_blank"} is recommended.

Following is an example that achieves the desired outcome. **Notice the need to set the root logger to DEBUG**. This is required as it will be the lowest log level you will be able to configure as per request. If INFO would be set there, you wouldn't be able to go any lower than that (DEBUG being the lowest, ERROR the highest).

However, the default log level is still INFO, as it is enforced by the *DefaultThreshold* attribute of the Filter.

{% highlight xml %}
<root level="DEBUG">
  <appender-ref ref="STDOUT"/>
</root>
<turboFilter class="ch.qos.logback.classic.turbo.DynamicThresholdFilter">
  <Key>X-Log-Level</Key>
  <DefaultThreshold>${LOG_LEVEL:-INFO}</DefaultThreshold>
  <MDCValueLevelPair>
    <value>ERROR</value>
    <level>ERROR</level>
  </MDCValueLevelPair>
  <MDCValueLevelPair>
    <value>WARN</value>
    <level>WARN</level>
  </MDCValueLevelPair>
  <MDCValueLevelPair>
    <value>DEBUG</value>
    <level>DEBUG</level>
  </MDCValueLevelPair>
</turboFilter>
{% endhighlight %}

### Log4j 2 configuration

In Log4j 2 the solution is a bit more straightforward to understand. Consider the value of *X-Log-Level* present in MDC.

1. If the value is either TRACE or DEBUG, log events at that level will also be accepted.
2. If the value is something else (does not match any of *keyValuePair* list), INFO is assumed.
3. If there is no *X-Log-Level* at all, *onMismatch* ensures the filter is neutral, behaviour doesn't change.

Look for DynamicThresholdFilter in [Log4j's Filters documentation](https://logging.apache.org/log4j/2.x/manual/filters.html){:target="_blank"}.

{% highlight yaml %}
DynamicThresholdFilter:
key: X-Log-Level
onMatch: ACCEPT
onMismatch: NEUTRAL
defaultThreshold: INFO
keyValuePair:
  -
  key: TRACE
  value: TRACE
  -
  key: DEBUG
  value: DEBUG
{% endhighlight %}

## Don't believe what you see?

See those logging filters running. Checkout **[this project](https://github.com/juliaaano/archetypes/tree/master/sparkjava){:target="_blank"}** in GitHub. It's a Maven archetype that will generate a project with many interesting features. The per-request log level filter is one of them.
