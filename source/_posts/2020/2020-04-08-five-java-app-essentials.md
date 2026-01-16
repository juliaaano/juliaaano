---
title: 5 Java App Essentials
layout: post
date: 2020-04-08
location: Sydney, Australia
description: |
  Five essential non-funcional capabilities a microservice app should have.
comments: true
og_image: /images/five-app-essentials.png
---

You're building from scratch just another microservice and the programing language of choice is once again Java. What are the 5 non-functional capabilities you're more likely to need to set up before writing any business code? Well, that usually depends on the project's requirements, however, more often than not I find myself dealing with the same concerns over and over. Here, I'll show you what they are and **how to implement them in a lightweight, almost framework-free approach.**

<!--more-->

<figure class="image">
<img src="{{ site.cdn.https }}/images/five-app-essentials.png" alt="filters-in-action" class="image-center-2" loading="lazy">
<figcaption class="image-center-caption">Image: Top five.</figcaption>
</figure>

## Get Started

First of all, I acknowledge we are past another decade, where popular frameworks such as Spring Boot and [**Quarkus**](https://quarkus.io/){:target="_blank"} have taken over the Java development landscape. The examples shown here have been intentionally created to be independent of these frameworks.

Robert C. Martin [has once said](https://blog.cleancoder.com/uncle-bob/2014/05/11/FrameworkBound.html){:target="_blank"} software teams get excessively bound to frameworks to the point the control over the software architecture is lost. There's no doubt this resonates with his work on the [SOLID](https://en.wikipedia.org/wiki/SOLID){:target="_blank"} software design principles. Remember, higher-level policies of systems (business domain) should not depend on lower-level ones (frameworks).

Enough said, I rest my case and give you here my list of **five essential microservices capabilities**:

### 1. API

The most common way to reach a service from the "outside" is via an **HTTP API**. The majority of software backend applications nowadays implement some sort of REST API.

[**Spark Java**](https://sparkjava.com/){:target="_blank"} is a simple, yet powerful micro-framework that provides a DSL for rapid development of HTTP endpoints. It is less invasive compared to other web frameworks, but still offers a lot of power and flexibility.

{% highlight java %}
import static spark.Spark.*;

public class HelloWorld {
    public static void main(String[] args) {
        get("/hello", (req, res) -> "Hello World");
    }
}
{% endhighlight %}

I wrote a blog post in the past about Spark Java [**here**](https://www.juliaaano.com/blog/2017/02/21/make-simple-with-spark-java/).

### 2. Testing

Seeing that *~~REST~~* APIs are everywhere, we must think about how to **test** them.

[**Rest Assured**](https://rest-assured.io/){:target="_blank"} is a great option. It has been out there for a while, so chances are you have heard about it. In short, it's a Java DSL for testing of REST services.

{% highlight java %}
@Test
void greet_john() {

    final String jsonBody = format("{\"name\":\"%s\",\"surname\":\"%s\"}", "John", "Smith");

    given()
        .accept(JSON)
        .contentType(JSON)
        .body(jsonBody)
    .when()
        .post("/greeting")
    .then()
        .statusCode(200)
        .contentType(JSON)
        .body("greeting", not(nullValue()))
        .body("greeting", equalTo("Hello, John Smith!"));
}
{% endhighlight %}

Full example can be found in my [**GitHub**](https://github.com/juliaaano/archetypes/blob/master/sparkjava/src/main/resources/archetype-resources/src/test/java/route/GreetingRouteShould.java){:target="_blank"}.

### 3. Logging

Logging, in general, certainly deserves its own topic. Here I'll discuss specifically two related aspects of application logging: **correlation ID** and **log filter**.

#### 3.1. Correlation ID

In a world of distributed microservices, it's imperative to be able to trace requests that travel from one service to another.

For this reason, it is recommended that every logging statement should include a correlation identifier to the request that it belongs to.

In Java, a popular solution is to use a logging framework that supports [**MDC - Mapped Diagnostic Context**](https://logback.qos.ch/manual/mdc.html){:target="_blank"}. With MDC, you are given access to store information in the context of a thread. This allows for an elegant solution where a "Request ID" is set to MDC and later read and written by the logging framework.

The Request ID should originate from the incoming request and always propagate through by each service. A common approach is to use HTTP Headers to carry this information. The header names should be standardized, **X-Request-ID** being a usual example of a name.

If the incoming request does not bring the expected X-Request-ID header, the app should create one and be the originator of that request.

Here is an example of generating an X-Request-ID and assigning it to the MDC:

{% highlight xml %}
// APP-YEAR-DAYOFYEAR-randomUUID: APP-2020-150-194a89c21ffa
String correlationId = "APP-".concat(now().format(ISO_ORDINAL_DATE)).concat(randomUUID().toString().substring(23, 36));
MDC.put("X-Request-ID", correlationId);
{% endhighlight %}

And finally, an example of how to use X-Request-ID in [**Logback**](https://logback.qos.ch/){:target="_blank"}:

{% highlight xml %}
<appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
  <encoder>
    <pattern>%date [%thread] %-5level %logger{15} [%X{X-Request-ID}] - %msg%n</pattern>
  </encoder>
</appender>
{% endhighlight %}

Checkout working example from [**here**](https://github.com/juliaaano/archetypes/blob/master/sparkjava/src/main/resources/archetype-resources/src/main/java/spark/SparkContext.java){:target="_blank"}.

#### 3.2. Log Filter

Recently, [I have written a full post about log filters](https://www.juliaaano.com/blog/2020/01/20/request-log-level-filter/). You can jump straight there in case you're interested.

I recommend setting up log filters to enable the use case of **adjusting the log level on a per HTTP request basis**. In practice, it could let you access the DEBUG logging of a service in production, without having to restart for configuration updates.

### 4. Container

When it's time to ship your application there's nothing better than packaging in a container.

In the example I'll show you, [**Docker** is used to build and run the Java app](https://www.juliaaano.com/blog/2018/02/25/fast-java-builds-with-docker/), making the process portable and transparent regardless where it is executed.

{% highlight docker %}
### BUILDER IMAGE ###
FROM maven:3-jdk-11-slim as builder

COPY pom.xml /build/

RUN mvn --file build/pom.xml --batch-mode dependency:go-offline

COPY src /build/src/

RUN mvn --file build/pom.xml --batch-mode --offline package -DskipTests \
	&& mkdir app \
	&& mv build/target/app-*.jar app/app.jar

### PRODUCTION IMAGE ###
FROM openjdk:11-jre-slim

COPY --from=builder app/app.jar app/app.jar

WORKDIR /app

CMD ["java", "-jar", "app.jar"]
{% endhighlight %}

The code comes from [**this repo**](https://github.com/juliaaano/archetypes/tree/master/sparkjava){:target="_blank"}, where you also find samples to configure [Kubernetes and Istio](https://github.com/juliaaano/archetypes/tree/master/sparkjava/src/main/resources/archetype-resources/manifests){:target="_blank"}.

### 5. Pipeline

An application deployment pipeline should be set early on in the project. At least something to test and build the artifacts should be in place from the beginning.

[**Here's a proof of concept pipeline built for Travis CI**](https://github.com/juliaaano/archetypes/blob/master/sparkjava/src/main/resources/archetype-resources/.travis.yml){:target="_blank"}. The idea is to showcase the implementation of multiple stages where Java, Docker and Github releases are featured.

More on this topic to be seen in a previous [**post**](https://www.juliaaano.com/blog/2017/04/10/build-and-release-pipeline/) in this very same blog!

## Wrap up

Thanks for coming all the way here.

Everything you've seen is available and ready to be used in the format of Maven archetypes. To install them, visit [https://github.com/juliaaano/archetypes/](https://github.com/juliaaano/archetypes/).
