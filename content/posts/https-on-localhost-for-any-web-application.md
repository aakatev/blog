---
title: "HTTPS on Localhost for Any Web Application"
date: 2020-07-28T10:42:08-07:00
draft: false
tags: ["tutorial", "webdev", "beginners"]
featured: false
description: "Have you ever heard about Caddy? No? What a shame! With Caddy you get some much including TLS certs out of the box. Learn more about in this post."
---

Having a TLS certificate is not a common requirement for local development. Moreover, many tools, like Angular or Parcel allow you to seamlessly generate certs with a runtime options. That said, sometimes you might need to serve HTTPS traffic to an application that doesn't support TLS certificates auto-generation. In this cases, there is no elegant workaround, rather than actually generate the certificates manually. It can be done using tools, like openssl, and there is a number of great how-to articles on the topic, for example [this one](https://www.freecodecamp.org/news/how-to-get-https-working-on-your-local-development-environment-in-5-minutes-7af615770eec/). 

## One-Command TLS with Caddy

[Caddy](https://caddyserver.com/) is a web server written in go that among other features automates TLS certificates generation. All you need for Caddy to proxy traffic to your app is one simple command:

```sh
# considering the app is running on port 3000
caddy reverse-proxy --to http://localhost:3000
```

For more complex usecases, Caddy also has a notion of [`Caddyfile`](https://caddyserver.com/docs/caddyfile), which is the same as configuration file.

## Installation

For the install process, refer to the [Download](https://caddyserver.com/docs/download) section of the Caddy docs. 

Depending on preferred method of your installation, you might need to make your system trust the TLS certificates Caddy generates.

```bash
# adds certs into the local trust store
caddy trust
```

## Google Chrome Issue Fix

Up until Caddy's recent release, there is a [know issue](https://github.com/caddyserver/caddy/issues/3571) affecting Google Chrome browsers (or other Chrome-based).

![Alt Text](https://dev-to-uploads.s3.amazonaws.com/i/jy995xfcwgsp460r9ec7.png)

In case you see the warning from above, please check that you have the latest version of Caddy installed!