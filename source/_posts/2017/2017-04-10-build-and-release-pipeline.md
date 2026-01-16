---
title: Build and release pipeline
layout: post
date: 2017-04-10
location: Sydney, Australia
description: |
  Software build and release pipeline in Travis CI for a Java Maven based project.
comments: true
og_image: /images/pipeline.png
---

A guide to get you started with the implementation of a software build pipeline in **[Travis CI](https://travis-ci.org/){:target="_blank"}** that automatically gets your code released to GitHub and pushed to a Docker registry. It takes you through some extra features such as Java's JAR signing (GPG) and encryption of secret data for your build. The examples assume that Java and Maven are in use. Furthermore, if releasing to **[Maven Central](https://central.sonatype.org/pages/apache-maven.html){:target="_blank"}** is your goal, this guide will take you right there at the door.

<!--more-->

## Goals

For every commit pushed to the master branch in GitHub, the following tasks should be completed by Travis:

* Software is built and dependencies are resolved.
* Artifacts are signed.
* Docker image is built.
* Tests run.
* Image is pushed with tag 'latest' to [Docker Hub](https://hub.docker.com){:target="_blank"}.

These are the basics that should invariably happen. Additionally, as a consequence of the command:

{% highlight yaml %}
git tag v1.0.0 && git push --tags
{% endhighlight %}

Travis should also trigger:

* Maven to set a new version based on the Git tag name.
* Docker to push an image with the same tag as the Git tag name.
* Creation of a new GitHub release with all artifacts, javadocs, sources and signature files.

## Travis

Make sure Travis and GitHub integration are properly set up.

One of the great advantages of CI tools like Travis is that the build configuration is defined as code and version controlled with the rest of your project in Git. In practice, this means you should have a **.travis.yml** file checked in your repository.

{% highlight yaml %}
language: java

jdk:
  - oraclejdk8

services:
  - docker

cache:
  directories:
    - "$HOME/.m2"

before_install:
  # travis encrypt-file command automatically generates the openssl command
  - openssl aes-256-cbc -K $encrypted_88b828c73747_key -iv $encrypted_88b828c73747_iv -in codesign.asc.enc -out codesign.asc -d
  - gpg --batch --fast-import codesign.asc
  - if [ -n "$TRAVIS_TAG" ]; then
      mvn versions:set -DnewVersion=$TRAVIS_TAG;
    fi

install:
  - mvn install -DskipTests=true -B -V -Psign -Dgpg.passphrase=$GPG_PASSPHRASE
  - docker build -t $TRAVIS_REPO_SLUG .

script:
  - mvn test -B

after_success:
  - docker login -u=$DOCKER_USERNAME -p=$DOCKER_PASSWORD;
  - if [ -n "$TRAVIS_TAG" ]; then
      docker tag $TRAVIS_REPO_SLUG $TRAVIS_REPO_SLUG:$TRAVIS_TAG;
      docker push $TRAVIS_REPO_SLUG:$TRAVIS_TAG;
    elif [ "$TRAVIS_BRANCH" == "master" ]; then
      docker push $TRAVIS_REPO_SLUG;
    fi

deploy:
  provider: releases
  api_key:
    secure: encrypted-key-generated-by-travis-setup-releases-cli
  file_glob: true
  file:
    - target/app-*.jar
    - target/java-starter-*.jar
    - target/java-starter-*.jar.asc
  skip_cleanup: true
  on:
    repo: juliaaano/java-starter
    branch: master
    tags: true
{% endhighlight %}

## JAR Sign and Encryption

In the **before_install** step of the .travis.yml example above, there is a command to decrypt a codesign.asc.enc file to a decrypted codesign.asc one. This is done securely because my repository, in Travis, is the only one with a private key to decrypt it. Previously, I had used [Travis CLI in my local machine to encrypt](https://docs.travis-ci.com/user/encrypting-files){:target="_blank"} that file with the public key available in the corresponding Travis build repo.

The codesign.asc is nothing more than another private key I have once created with GPG. Since it is a requirement from Maven Central to have signed JARs, I found useful to include it as part of my builds. There are plenty of resources out there [explaining how to work with](https://central.sonatype.org/pages/working-with-pgp-signatures.html){:target="_blank"} the GnuPG tool.

A Maven [plugin](https://maven.apache.org/plugins/maven-gpg-plugin/){:target="_blank"} has the job to do the actual JAR signing. For this case, it assumes my key is set as default in the environment (gpg --fast-import). The passphrase is expected to be configured ahead in Travis as an environment variable: $GPG_PASSPHRASE.

There is a project with the **pom.xml** configured with GPG [here](https://github.com/juliaaano/payload/blob/1.0.0/pom.xml){:target="_blank"}.

## Docker

Pay attention to the variables **$DOCKER_USERNAME** and **$DOCKER_PASSWORD**. They should be manually assigned in Travis (same as $GPG_PASSPHRASE) and in my case they refer to my own Docker Hub credentials.

Besides the build and push steps, one good idea might be executing a 'docker run' during the 'script' stage and conditionally fail or pass the build.

## GitHub Release

Every successful build derived from master and with a tag is directly posted to a GitHub release. An access token (api_key) is required by Travis, but again the command line tool [handles that for you](https://docs.travis-ci.com/user/deployment/releases/){:target="_blank"}.

## Conclusion

Much has been said about continuous delivery. I strongly agree it is a matter of process and people before anything else. Nonetheless, I don't find examples or how-to's out there quite often. Probably because the resulting implementation is specific to the development process in place. I hope you can use this to get you started and evolve it towards your own deployment pipeline.

The solution presented in this blog came from my Spark Java Maven **Archetypes** project. Check out the source code at [https://github.com/juliaaano/archetypes/tree/master/sparkjava](https://github.com/juliaaano/archetypes/tree/master/sparkjava){:target="_blank"}.
