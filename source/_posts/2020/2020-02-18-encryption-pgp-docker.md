---
title: Easy encryption with PGP and Docker
layout: post
date: 2020-02-18
location: Sydney, Australia
description: |
  A trick that combines Docker containers, GPG and PGP encryption.
comments: true
og_image: /images/keyboard-privacy.jpg
---

Encryption is complicated. People don't pay too much attention because the process and tools are often cumbersome. In this post, I show you how to encrypt data effortlessly by combining tools like [**GPG**](https://gnupg.org/){:target="_blank"} and **Docker** (or [**Podman**](https://podman.io/){:target="_blank"}) containers. Your privacy in this wild wild internet is guaranteed!

<!--more-->

## TL;DR

The goal is **for anyone** to encrypt a message **from anywhere** addressed to a recipient (in this case myself):

{% highlight bash %}
echo "send me a secret" | docker run -i juliaaano/encrypt
{% endhighlight %}

## Show me how

The intent is to provide a good experience by abstracting the use of GPG with *~~Docker~~* Linux containers.

The container image that I use is lightweight, has GPG installed and imports my public PGP key.

{% highlight docker %}
FROM debian:stable-slim

RUN apt-get update && apt-get install -y gnupg2 curl

RUN curl -sSL https://www.juliaaano.com/key.asc | gpg --import -

ENTRYPOINT ["gpg", "--trust-model", "always", "--encrypt", "--armor", "--output", "-", "--recipient", "juliaaano"]
{% endhighlight %}

## About PGP/GPG

So far it has been assumed a PGP key pair exists so you have a public key for encryption and "hopefully" its private counterpart for decryption.

Creating a key pair with GPG is easy, and there are several [resources available](https://help.github.com/en/github/authenticating-to-github/generating-a-new-gpg-key){:target="_blank"}.

Once you've got your keys, you can build and distribute your container image so anyone can send encrypted messages to you. You still need to deal with GPG to decrypt them yourself.

## Usage examples

<ol>
<li>
Encrypt a text message or a text file:
{% highlight bash %}
echo "send me a secret" | docker run -i juliaaano/encrypt
cat my-sample-file.txt | docker run -i juliaaano/encrypt
{% endhighlight %}
</li>
<li>
Save encrypted output to a file:
{% highlight bash %}
echo "send me a secret" | docker run -i juliaaano/encrypt > secret.txt.asc
{% endhighlight %}
</li>
<li>
Copy encrypted output to the clipboard (MacOS only):
{% highlight bash %}
cat my-sample-file.txt | docker run -i juliaaano/encrypt | pbcopy
{% endhighlight %}
</li>
<li>
Encrypt binary (non-text) files:
{% highlight bash %}
docker run -v $(pwd):/tmp juliaaano/encrypt /tmp/myfile.zip > myfile.zip.asc
{% endhighlight %}
</li>
<li>
Use Podman containers instead of Docker:
{% highlight bash %}
echo "send me a secret" | podman run -i juliaaano/encrypt
cat my-sample-file.txt | podman run -i juliaaano/encrypt
{% endhighlight %}
</li>
</ol>

## Summary

The source code for this project can be found at [**juliaaano/encrypt**](https://github.com/juliaaano/encrypt){:target="_blank"}.

If you like it, comment with an **encrypted** message down below :-)
