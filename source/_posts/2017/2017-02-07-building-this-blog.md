---
title: "Building this Blog"
layout: post
date: 2017-02-07
location: Sydney, Australia
description: |
  The history, technology, tools and practices behind this blog.
comments: true
---

A few weeks ago I decided to engage in a project of building a blog. I was looking for challenges, I wanted to build something of my own, without using some of these well known platforms like Wordpress, Blogger, etc. It was more about the journey and satisfaction of dealing with a domain that I was never very familiar with: **front-end development**.

<!--more-->
The result is this website you are seeing now. Although it may look simple (that's always the goal!), there has been many things I've been through during this project. I would like to share with you the major practices and tools I learned the past weeks. This way I hope I can help you if you are also interested on building your own website.

I'll be brief, most of the topics deserve their own blog posts, and I'm looking forward to write more about them in the future.

### Jekyll

The great deal about this website is that it is completely static. I use **[Jekyll](https://jekyllrb.com){:target="_blank"}** to generate, from templates, the whole content on every source commit. This means no dynamic content, no databases, no [CMS](https://en.wikipedia.org/wiki/Content_management_system){:target="_blank"}; just **plain html**. I reckon this makes development much simpler because I've established just enough architecture to solve my problem.

### GitHub Pages

Here comes the magic! **[GitHub Pages](https://pages.github.com){:target="_blank"}** has a wonderful [integration with Jekyll](https://help.github.com/articles/about-github-pages-and-jekyll/){:target="_blank"}. Everytime you push code to your pages repository/branch, GitHub will build your site. You don't need to keep stored your generated web site, because GitHub will do that for you behind the scenes. In the end you get continuous integration, deployment and hosting for free.

### Disqus

After realising the benefits of having a static website, I asked myself: how am I going to provide comments for the posts? Here **[Disqus](https://disqus.com){:target="_blank"}** comes into play. Just like Google [Analytics](#analytics), you add a javascript to your html page and bam! It's there.

### Analytics

I guess **[Google Analytics](https://www.google.com/analytics/){:target="_blank"}** is de facto standard for this kind of thing. If you know better solutions, I'm happy to hear.

### Domain (DNS)

Time to setup a custom domain name. I've long used juliaaano as an online identity and I hope one day I can tell you the story why. DNS is provided by **[Amazon Route 53](https://aws.amazon.com/route53/){:target="_blank"}**. All I had to do there was to create a [couple of CNAME entries here and there](https://help.github.com/articles/using-a-custom-domain-with-github-pages/){:target="_blank"}.

### Accelerated Mobile Pages

I'm proud to say this website is powered by **[AMP](https://www.ampproject.org){:target="_blank"}**. I stumbled upon this technology by accident and got immediately really excited about it. Besides ensuring your pages load super fast, AMP helps you to build better html. Other than that, it's a step towards the [Progressive Web Apps](https://en.wikipedia.org/wiki/Progressive_web_app){:target="_blank"} movement. It's been designed to delivery content to mobile devices, but I see no reason why I wouldn't use with desktops.

### Content Delivery Network (CDN)

Since I've decided to embrace performance by using AMP, nothing more natural than leverage it with the power of CDNs. All my images, javascript and fonts are delivered by **[Amazon CloudFront](https://aws.amazon.com/cloudfront/){:target="_blank"}**, backed by [Amazon S3](https://aws.amazon.com/s3){:target="_blank"}. If you decide to have fun with this stuff, pay special attention to cache headers and Cross-Origin Resource Sharing (CORS) settings. 

### Compress HTML

Getting the html optimised to be delivered over the network is a piece of cake with **[Jekyll Compress Html](https://github.com/penibelst/jekyll-compress-html){:target="_blank"}**.

### Responsive

It has been challenging to learn a few CSS tricks to get this website look decent in different screen sizes. I assume you should always have this in mind.

### Accessibility

I hope this blog is friendly to people who are visually impaired. I've favoured HTML5 tags (header, nav, section, etc.) instead of divs and I've tried to use **[WAI-ARIA](https://www.w3.org/WAI/intro/aria){:target="_blank"}** best practices.

### Fonts

Why not have a deterministic approach to how your text will look like? I've noticed that major websites use their own **typeface**. Although I didn't want to license ($$$) a paid web font at this moment, I liked the idea to self host the [free fonts](https://github.com/showcases/fonts){:target="_blank"} my blog is using. The benefits are a stronger visual identity and a more predictable behavior, since you don't rely on the browser picking up the font for you.

### Font Awesome

How awesome is **[Font Awesome](https://fontawesome.com){:target="_blank"}** with its endless number of icons. You can setup a private account with their CDN where you are able to do some customisations as well as configure to asynchronously load the fonts in your page. Awesome!

### Favicons

Nowadays favicons go beyond the scope of displaying a nice little image in your browser when a web page is bookmarked. There are specific icons for Android, iPhone and so on. Therefore, if you want to look good in all different platforms, make sure you define them properly [here](https://realfavicongenerator.net){:target="_blank"} or [here](https://www.websiteplanet.com/webtools/favicon-generator){:target="_blank"}.

### Atom Feeds (RSS)

I keep a RSS-like feed of all my posts. The **[jekyll-feed](https://github.com/jekyll/jekyll-feed){:target="_blank"}** plugin does that seamlessly for me.

### Meta Tags (Open Graph/Twitter)

This becomes relevant when someone shares a page from your website in a social network. You need to define which image, title and text to display when Facebook/Twitter render the post/tweet card, for example. I'm using a combination of **[Open Graph](https://developers.facebook.com/docs/sharing/opengraph){:target="_blank"}** and **[Twitter Cards](https://dev.twitter.com/cards/overview){:target="_blank"}**.

### SEO

**[Jekyll SEO Tag](https://github.com/jekyll/jekyll-seo-tag){:target="_blank"}** to the rescue.

### Sitemap

A sitemap makes easier for Google to find my pages (SEO++). The plugin **[Jekyll Sitemap](https://github.com/jekyll/jekyll-sitemap){:target="_blank"}** creates a new sitemap.xml file on every build.

### W3C

I often test my site against the **[W3C Validator](https://validator.w3.org){:target="_blank"}**. It helps me to spot malformed html and stay compliant with W3C standards.

### HTMLProofer

Fantastic tool to validate generated html output: **[HTMLProofer](https://github.com/gjtorikian/html-proofer){:target="_blank"}**.

## Conclusion

It's been a nice learning experience to go through this road. As a developer, I wanted to be a bit more professional by building my presence online with my own hands.

I would like to aknowledge and thank **[Yegor Bugayenko](http://www.yegor256.com){:target="_blank"}** for his blog and [book](http://www.yegor256.com/256-bloghacks.html){:target="_blank"}. They've both served to me as a model and foundation for this project.
