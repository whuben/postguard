---
title:  "PostGuard: A lua module demo for protecting post request"
date:   2017-07-02 15:00:00
categories: [Code]
tags: [lua]
---

### The idea of [PostGuard](https://github.com/whuben/postguard)

#### 0x01 Does every post request has a "referer" in the header?

The idea is based on the assumption that every post request must bring with a "referer". Actually, most post request will bring with a "referer" which is accessed before submitting the post request. According to my consideration, there are two situation 
<!--more-->
that a post reqeust may not bring with a "referer". First situation: the post request is crossing two web sites and the two sites use different protocols such as https,http. Another situation is that the web server has some special api provided for machine to access directly. For dealing with the two special situation, a white list may figure out.

#### 0x02 How to verify whether the "referer" brought by a post request has been accessed resently?

Every GET request will be handled by fetching some basic information as a fingerprint of this GET request, and the fingerprint will be stored in the shared dict with an custom expire time(600s by default). In order to identify the client user, the basic information includes the ip of client user, the ip of web server, the accessed URL. If a custom user tag (usually a cookie tag) is defined in the configuration file, then the custom tag will be also included in the basic info.

#### 0x03 Learning Mode
Turn on the learning mode by setting the field "`mode`" to 1 in `config.lua`. Then all the requests will be regarded as legal, the "referer",ip of server and the request URL will be logged for analysis to fetch detection rules using in detection mode.  

#### 0x04 Extension based on PostGuard
You can extend the PostGuard to add some other functions. For example, restrict the referer of every post according to your customed configuration for defending CSRF attack, restrict the frequency of some sensitive API for denfending CC attack,etc...

#### source code of PostGuard: https://github.com/whuben/postguard