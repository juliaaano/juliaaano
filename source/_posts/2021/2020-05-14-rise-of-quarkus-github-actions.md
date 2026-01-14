---
title: The Rise of Quarkus and GitHub Actions
layout: post
date: 2021-05-14
location: Sydney, Australia
description: |
  Continuous integration pipeline for Quarkus and Java applications using GitHub Actions. 
comments: true
og_image: /images/pipelines-by-sea.jpeg
---

Thanks to [**Quarkus**](https://quarkus.io/){:target="_blank"} and [**GitHub Actions**](https://github.com/features/actions){:target="_blank"}, I now find enjoyable to do Java development and create continuous integration (CI) workflows for my applications. In this post, you will learn how to efficiently build and push container images using the GitHub ecosystem, as well as look at examples on how to write pipelines with good practices in mind. Finally, I will demonstrate a few tricks specific to building Quarkus and Java apps with Actions.

<!--more-->

<figure class="image">
<img src="{{ site.cdn.https }}/images/pipelines-by-sea.jpeg" alt="pipelines-by-sea" class="image-center" loading="lazy">
<figcaption class="image-center-caption">Image: Pipelines by the sea.</figcaption>
</figure>

First and foremost, let me just define what continuous integration or CI pipeline is for the purposes of this article.

It is specifically the process to build, test and package the software artifact in a container, so it can be ready to be deployed in any given environment.

## Quarkus

[**Quarkus**](https://quarkus.io/){:target="_blank"} is an amazing Java stack for developing modern cloud-native applications. The example used throughout this blog is an app written in Quarkus. Take some time to explore the [source code here](https://github.com/juliaaano/quarkus){:target="_blank"}.

## GitHub Actions

Think of [GitHub Actions](https://github.com/features/actions){:target="_blank"} as the CI tool, a replacement for Jenkins or Travis CI, for example. The aspect I like most about it is the fact it's so well integrated with the GitHub repository. This can be empowering for developers who can control and get feedback from their CI pipelines in the same place where the code and pull requests are managed.

## GitHub Packages

GitHub's response to having a container registry comes with [GitHub Packages](https://github.com/features/packages){:target="_blank"}. The container image produced by the pipeline featured in this blog is pushed to the *ghcr.io* registry. Similar to Actions, Packages are well integrated with GitHub's repository, especially the way access control is granted to the pipeline.

## Time for Action~~s~~

The CI pipeline is defined as code in what GitHub call workflows. These are yaml files contained inside the *.github/workflows/* directory.

Next, I will highlight the best practices and patterns that can be found in the workflows of the Quarkus [example application](https://github.com/juliaaano/quarkus){:target="_blank"} of this blog.

### The Reuse of Existing Actions

{% highlight yaml %}
{% raw %}
- name: login ghcr.io
  uses: docker/login-action@v1.8.0
  with:
      registry: ghcr.io
      username: ${{ github.actor }}
      password: ${{ secrets.GITHUB_TOKEN }}
      logout: true
{% endraw %}
{% endhighlight %}

Perhaps one of the best traits in Actions is the ability to import existing actions in order to execute even trivial tasks. The reason I say this is because pipeline code is not something that can be (at least easily) **tested**. Having the opportunity to delegate tasks to code that have been tried before increases the overall trust in the pipeline as well as reducing the errors and maintenance.

In the example above, I felt tempted to ignore using the action and instead just run a *docker login* shell command. However, that would still be prone to error (think of leaking the password); I also would not have handled the **logout** having coded the logic myself.

### Maven Cache

{% highlight yaml %}
{% raw %}
- name: cache ~/.m2
  uses: actions/cache@v2
  with:
    path: ~/.m2
    key: ${{ runner.os }}-m2-${{ hashFiles('**/pom.xml') }}
    restore-keys: ${{ runner.os }}-m2
{% endraw %}
{% endhighlight %}

Maven is famous for downloading half, if not the entire, internet. Jokes aside, it is wise to cache the dependencies as it normally happens in your local dev machine.

The level of abstraction provided by the action is great, it gives the developers flexibility and easiness to understand.

Cache invalidation will basically occur whenever the pom.xml changes.

### Code Scanning

Another powerful feature is the [code scanning](https://github.com/features/security){:target="_blank"} action. Powered by CodeQL, it can be found in the Quarkus app as a separate [workflow](https://github.com/juliaaano/quarkus/blob/master/.github/workflows/scanning.yml){:target="_blank"}.

<figure class="image">
<img src="{{ site.cdn.https }}/images/github-code-scanning.png" alt="github-code-scanning" class="image-center" loading="lazy">
<figcaption class="image-center-caption">Image: GitHub code scanning.</figcaption>
</figure>

Security vulnerabilities are reported at the pull request level, in the code diff. A brilliant application of the shift-left security concept.

### Permissions

All calls to GitHub APIs are authenticated using a GITHUB_TOKEN which is present by default in the workflow. The permissions assigned to this token can be configured as code inside the workflow definition.

{% highlight yaml %}
permissions:
  packages: write
  security-events: write
{% endhighlight %}

Following the **least privilege** security principle, I set everything to read-only at the repository level and then explicitly grant the required permissions as displayed above.

### Container Builds with JIB

In the obsession to find the most efficient way to build container images, I found [JIB for Quarkus](https://quarkus.io/guides/container-image#jib){:target="_blank"}. Next is an extract straight from the docs:

*The extension quarkus-container-image-jib is powered by Jib for performing container image builds. The major benefit of using Jib with Quarkus is that all the dependencies (everything found under target/lib) are cached in a different layer than the actual application making rebuilds really fast and small (when it comes to pushing). Another important benefit of using this extension is that it provides the ability to create a container image without having to have any dedicated client side tooling (like Docker) or running daemon processes (like the Docker daemon) when all that is needed is the ability to push to a container image registry.*

To use it with Quarkus simply add the dependency:

{% highlight xml %}
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-container-image-jib</artifactId>
</dependency>
{% endhighlight %}

Then add the following argument to the Maven build.

{% highlight bash %}
$ mvn package -Dquarkus.container-image.push=true
{% endhighlight %}

### Image Labels

Container image labels are relevant. In the example I give, a label is used to trace back to the git commit where that image was built from. With Quarkus, JIB and GitHub Actions, this is done by adding the following argument to the Maven build:

* *'-Dquarkus.jib.labels."org.opencontainers.image.revision"='$GITHUB_SHA*

Pay attention to the use of single and double quotes as it makes a difference in the command line.

Also, it is worth mentioning the label name was not chosen arbitrarily, but based on standards from the [Open Container Initiative](https://github.com/opencontainers/image-spec){:target="_blank"}.

## Conclusion

You have seen a little bit of how to do continuous integration using modern frameworks. Despite the tools, what really matters is how close to the developers the process can get. With GitHub Actions and a modern language like Quarkus, people who get to write the code can now feel more than empowered to build and ship code fast. After all, that is the point of disciplines like DevOps and Continuous Delivery.

There is way more you can learn by going through the source code at:

* [https://github.com/juliaaano/quarkus](https://github.com/juliaaano/quarkus){:target="_blank"}

Bonus: worth checking there how the pipeline handles build and testing in Quarkus **NATIVE** mode.
