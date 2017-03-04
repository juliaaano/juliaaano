---
title: API & Platforms are the new SOA
layout: post
date: 2017-03-04
location: Sydney, Australia
description: |
  The API / Platform space and Service Oriented Architectures have much in common, specially the appetite from vendors to sell their solutions.
comments: true
og_image: /images/blue-bus.png
---

The business around API's is growing these days. I've been reading a lot about how companies should be building platforms to achieve innovation and reach new markets. It's all about opening your business to let others create value on top of it. The financial industry (i.e. banks) is taking the lead in this area. One thing I didn't realize before is how similar all this is to the old gold SOA.

<!--more-->

When I think about Service Oriented Architectures, I remember the promise of having areas of business modeled as **web services** that were supposed to be shared and discoverable on the internet. A significant fact which represented this period was the vendor-mafia that came and raped the industry by pushing their heavy weight ESB products. 

<amp-img
	media="(min-width: 600px)"
    src="{{ site.cdn.http }}/images/blue-bus.svg"
    alt="enterprise-service-bus"
    width="1"
    height="1"
	class="image-right"
	layout="responsive">
</amp-img>

<amp-img
    media="(max-width: 599px)"
    src="{{ site.cdn.http }}/images/blue-bus.svg"
    alt="enterprise-service-bus"
    width="1"
    height="1"
    layout="responsive">
</amp-img>

It turns out Platforms & API's are not proposing something much different from what people expected from SOA before. I'm afraid the same old vendors have already perceived that.

Not long ago I've been in a conference focused on the API/Platform space. I noticed a bunch of companies with bundle products that remembered pretty much the enterprise service buses we learned to be suspicious about. More specifically, I've seen solutions that addressed the issues of the enterprise in **horizontal** layers, where API's were exposed in standard ways with some sort of orchestrator in the middle.

While I draw this parallel between API's and SOA, I can't avoid to remember how many discussions I've seen around Microservices and SOA. I'm starting to guess that was a **wrong** comparison. The new SOA is "The Platform". Microservices are just an implementation detail.

Lastly, I do understand there are many differences between the new API movement and SOA. One example is the **developer engagement**. It's a lot more interesting to build apps on top of friendly JSON and hypermedia driven api's than it used to be with the problematic XML SOAP protocol. However, in principle, I believe both approaches share the same purpose.
