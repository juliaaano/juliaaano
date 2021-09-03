---
title: Fast Java builds with Docker
layout: post
date: 2018-02-25
location: Sydney, Australia
description: |
  A smart way to cache Maven builds in Docker.
comments: true
og_image: /images/docker-multi-stage-builds.jpg
---

There is a common pattern emerging which is to use Docker to **build** the software artefact. This approach has become popular since your machine or CI agent is not required to have anything installed but Docker. However, if you have tried this before with **Java/Maven**, you are most likely to know how **slow** it can be to see Maven download half of the internet inside the container in every single run. Here I show you how to address that issue with a simple trick. 

<!--more-->

What we want to do is to copy the **pom.xml** and the **app sources** in two separate steps. 

{% highlight docker %}
FROM maven:3

COPY pom.xml /build/

RUN mvn --file build/pom.xml --batch-mode package

COPY src /build/src/

RUN mvn --file build/pom.xml --batch-mode --offline package \
	&& mkdir app \
	&& mv build/target/app-*.jar app/app.jar \
	&& rm -rf build
{% endhighlight %}

The two most important things in this example are running Maven with the pom.xml in isolation and once the sources are added, running Maven again with the *--offline* option set.

This is only possible thanks to Docker's built-in cache. Before you ask, yes, if you make any changes to the pom.xml you will invalidate the subsequent cached instructions and you will download half of the internet again. It only works under the assumption that application code is changed more often than the dependency management configuration.

### Multi-stage builds

The previous example alone doesn't provide much context. After all, what do you do with that Dockerfile?

I hope you have heard about **[Docker multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/){:target="_blank"}**. It has been introduced to encourage the use of docker as a builder engine.

{% highlight docker %}
### BUILDER IMAGE ###
FROM maven:3 as builder

COPY pom.xml /build/

RUN mvn --file build/pom.xml --batch-mode package

COPY src /build/src/

RUN mvn --file build/pom.xml --batch-mode --offline package \
	&& mkdir app \
	&& mv build/target/app-*.jar app/app.jar \
	&& rm -rf build

### PRODUCTION IMAGE ###
FROM openjdk:8-jre-alpine

COPY --from=builder app/app.jar app/app.jar

CMD ["java", "-jar", "app.jar"]
{% endhighlight %}

The idea is to show how easy Docker can be used to both build and run your software. Ultimately, entire pipelines could be created with just a Dockerfile and multi-stage builds. That would be a very comfortable position for the developer who would be able to execute all these stages locally exactly the same as the CI agent. 

More information at [https://github.com/juliaaano/archetypes](https://github.com/juliaaano/archetypes){:target="_blank"}
