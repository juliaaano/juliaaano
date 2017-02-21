---
title: Make it simple with Spark Java
layout: post
date: 2017-02-21
location: Sydney, Australia
description: |
  Take it easy and develop REST APIs in Java. Fast, elegant, declarative and functional.
comments: true
og_image: /images/sparkjava-icon.png
---

About an year ago I've stumbled upon this interesting little framework called **[Spark Java](http://sparkjava.com/){:target="_blank"}**. If you are looking for a lightweight alternative to quickly develop **REST APIs in Java**, you might like this.

<!--more-->

{% highlight java %}
public static void main(String... args) {
  get("/hello", (req, res) -> "Hello World");
}
{% endhighlight %}

Pretty straightforward. Spark Java leverages Java 8 to provide an easy to use and understand api. Method get() registers the endpoint and starts up an embedded Jetty server to handle the incoming http requests.

Look at this other example:

{% highlight java %}
public static void main(String... args) {
  final Repository repository = new Repository();
  post("/hello", "application/json", (req, res) ->
    Entity entity = repository.save(req.body());
    res.status(201);
    return entity;
  }, new JsonResponseTransformer());
}
{% endhighlight %}

Here we declare a **POST** endpoint that only gets called if the client sets Accept: "application/json" request header. Moreover, we return an entity that is serialized to **JSON** using an object that implements ResponseTransformer; it could possibly use [Gson](https://github.com/google/gson){:target="_blank"} behind the scenes.

Spark Java has not invented anything new. The design is pretty much taken from Ruby's Sinatra framework.

### In summary

Simple, easy to maintain and understand.

No "magic". Get rid of all the levels of indirection that a framework like Spring MVC introduces.

Better **separation of concerns**. Spark Java does not try to save the world.

### There's more...

Let's go a bit fancy. Here's a design idea you can use when there are multiple endpoints to configure.

First, create a builder interface:

{% highlight java %}
public interface EndpointBuilder {
  void configure(Spark spark, String basePath);
}
{% endhighlight %}

Now, let's say you have one of many other rest endpoints resources to set up:

{% highlight java %}
public class CustomerEndpoint implements EndpointBuilder {

  private final CustomerService customerService;

  public CustomerEndpoint(CustomerService service) {
    this.customerService = service;
  }

  @Override
  public void configure(Spark spark, String basePath) {
    spark.get(basePath + "/customer", (req, res) -> {
      return "hello";
    });
  }
}
{% endhighlight %}

Finally, create a RestContext class that will hold the spark instance and will enable you to configure whatever routes you wish:

{% highlight java %}
public class RestContext {

  private static final Logger logger = LoggerFactory.getLogger(RestContext.class);
  private final Service spark;
  private final String basePath;

  public RestContext(int port, String basePath) {
    this.basePath = basePath;
    spark = Service.ignite().port(port); // import spark.Service;
  }

  public void addEndpoint(EndpointBuilder endpoint) {
    endpoint.configure(spark, basePath);
    logger.info("REST endpoints registered for {}.", endpoint.getClass().getSimpleName());
  }

  // Then you can even have some fun:
  public void enableCors() {
    spark.before((request, response) -> {
      response.header("Access-Control-Allow-Origin", "*");
      response.header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
      response.header("Access-Control-Allow-Headers", "Content-Type, api_key, Authorization");
    });
    logger.info("CORS support enabled.");
  }
}
{% endhighlight %}

You should be able to use this context class in your main method (and optionally in your test classes):

{% highlight java %}
public static void main(String... args) {
  RestContext context = new RestContext(8080, "/api");
  context.addEndpoint(new CustomerEndpoint(new CustomerService()));
  context.addEndpoint(new AnotherEndpoint()); // you can add or remove as many as you want.
  context.enableCors();
}
{% endhighlight %}
