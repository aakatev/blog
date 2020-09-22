---
title: "Web Security 101"
date: 2020-07-17T10:42:08-07:00
draft: false
tags: ["security", "webdev", "introduction", "todayisearched"]
featured: false
description: "I did a research on the topic of web security, and now sharing the findings with my readers."
---

The current document was born as part of my personal research on topic of security related to Software (SW), and specifically Web Applications. It is by no means comprehensive, but can be a good place to start getting familiar with the most common threats developers face on the World Wide Web (WWW). Each section aims to introduce a problem, or a technology. Briefly give to a reader an overview of the issue, and provide references for the further research.

# Threat Model

> Threat Model is used to identify and explore threats and mitigations within the context of protecting something of value.

Threat Model is applicable to a wide range of things, including SW, hardware (HW), networks, distributed systems, and etc. There are very some technical products which cannot be threat modeled. Although threat modelling can be done at any stage of development, it is preferably to do it as early as possible, so that the findings can be applied to the design of the system.

Most thread modelling researches aim to answer the following questions:

1. What system are we building?
   - Application architecture
   - Application data flow
   - Application data type
   - Technologies used
2. What can go wrong?
   - "Branistorming" phase
   - Good stage to consult with STRIDE, Kill Chains, CAPEC and others structures models
3. What are we going to do about that?
   - Applying result of the question 2 to the system from the question 1
   - Also known as Threat Modeling Outputs
4. Did we do a good enough job?
   - Testing, and checking whether means from the question 3 are sufficient

[Lean more](https://owasp.org/www-community/Application_Threat_Modeling) about Threat Model.

# Open Web Application Security Project (OWASP)

> The [OWASP](https://owasp.org) is a nonprofit foundation that works to improve the security of software. Through community-led open source software projects, hundreds of local chapters worldwide, tens of thousands of members, and leading educational and training conferences, the OWASP Foundation is the source for developers and technologists to secure the web.

## OWASP Top Ten

The OWASP Top 10 is a standard awareness document for web application security. It represents a broad consensus about the most critical security risks to web applications. Project has several itteration, and usual update cycle is 3 to 4 years.

The most recent itteration of Top Ten:

1. Injection
2. Broken Authentication
3. Sensitive Data Exposure
4. XML External Entities (XXE)
5. Broken Access Control
6. Security Misconfiguration
7. Cross-Site Scripting (XSS)
8. Insecure Deserialization
9. Using Components with Known Vulnerabilities
10. Insufficient Logging and Monitoring

[Learn more](https://owasp.org/www-project-top-ten/) about OWASP Top Ten.

## OWASP Web Security Testing Guide

The WSTG is the premier cybersecurity testing resource for web application developers and security professionals. It is a comprehensive guide to testing the security of web applications and web services. Created by the collaborative efforts of cybersecurity professionals and dedicated volunteers, the WSTG provides a framework of best practices used by penetration testers and organizations all over the world.

[Learn more](https://owasp.org/www-project-web-security-testing-guide/) about OWASP WSTG.

## OWASP Cheat Sheet Series

The OWASP Cheat Sheet Series was created to provide a concise collection of high value information on specific application security topics. These cheat sheets were created by various application security professionals who have expertise in specific topics.

[Learn more](https://cheatsheetseries.owasp.org/) about OWASP Cheat Sheet Series.

# Common Attacks

This section introduces 3 common attack vectors, and ways to prevent the exploits. 

## Cross-Site Scripting (XSS)

### Overview

An attacker injects code in place of a text, and force application to execute it. Prevalant vector of attack against client side applications. Older browsers, like IE, are especially sensitive to this kind of attack. Injection itself commonly occures using Man-in-the-Middle attack, and HTTPS downgrade.

### Types

- Stored XSS - Code injection in a database or other persistent storage.
- Reflected XSS - Affected code is injected in web application client from server, or other outside source.
- DOM Based XSS - Attacking a web application client directly, without any server involvement.
- Blind XSS - Similar to Stored XSS. Attacking some other application used by the main application as runtime dependency.

### Common Danger Zones

- WYSIWYG (User generated rich text)
- Non-text inputs (File uploads)
- Embedded content
- Browser plugins
- Third party UI libraries
- Third file compression libraries
- Anywhere user can insert URL directly
- Anywhere user input is sent back (Reflected XSS)
- Anywhere query parameters are rendered into DOM (DOM Based XSS)
- Anywhere where web application renders elements directly into DOM using JS (especially using `innerHTML` property of an element)
- Anywhere unsanitized user data is processed by script, or template engine
- Depending on browser, pdf viewer can execute third party JS, and thus are vulnareble

### Defenses

#### Most common prevention measures are:

- Any form of user input should be treated as value, not as code
- Sanitize data before it gets stored into persistent storage
- Sanitize data before it renders to end user
- Restrict supported upload formats
- Compress images before storing
- Don't use unescaped expressions while rendering or templating UI
- Use only reliable third party UI and file compression libraries, providing a list of known vulnerabilities, and customer support

#### Content Security Policy (CSP)

Browsers JS engine cannot tell the difference between scripts fetched from different origins. Eventually, all the scripts get executed as single context. CSP allows to tell supported browsers which sources they could execute, and which not. CSP is set as HTTP response header.

#### Useful CSP directives:

- child-src - whitelist frames ans workers
- connect-src - whitelist HTTP(fetch), WS, and EventSource
- form-action - whitelist form post
- img-src, media-src, object-src, style-src - whitelist of media and style
- upgrade-insecure-requests - upgrade HTTP links to HTTPS
- default-src - general fallback, for all resources types

## Cross-Site Request Forgery (CSRF)

### Overview

CSRF attack is based on taking advantage of browser passing cookies and basic authentication credentials along with requests. Attacker insert a resource, or snippet of code (such as HTML form) to another website, containing a link to the target site. Web browser attempting to load the resource, will make a request with the cookie/credentials attacked.

### Common Danger Zones

- Server API endpoints (especially handling sensitive data)
- Applications implementing cookie or basic authentication schemes

### Defenses

##### Most common prevention measures are:

- Stay align with REST conventions while implementing API (distinguish safe and idempotent methods)
- Implement authentication using different schmes (web storage)

##### CSRF Token

The server generates some value, and transmitted it to the client. Client included this value with subsequnet request. The value should be unique, and unpredictable in order for the scheme to be secure.

##### Validate Origin

Modern browsers attach Origin header, which cannot be altered by client side scripts. Origin can be checked on the server. If request is coming through proxy, the origin header might be replaced with Referer.

##### Cross-Origin Resource Sharing (CORS)

A mechanism to tell a browsers to give a web client application running at one origin, access to some resources from a different origin. CORS is set as a HTTP header

## Clickjacking

### Overview

Clickjacking, or "UI redress attack", occures when an attacker tricks a user into clicking on a button or link on another page rather than the user originally intended. Thus, the attacker is "hijacking" clicks and routing them to another page. Some versions of the attack can capture keystroked as well.

### Common Danger Zones

- Almost anywhere user can interact with your application
- Most commonly, forms, text inputs, buttons, file uploads, and etc

### Defenses

##### X-Frame-Options Response Headers

The X-Frame-Options header can be used to indicate whether or not a browser should be allowed to render a page inside frame/iframe element. Sites can use the header to ensure that their content is not going to be embeded.

X-Frame-Options headers can have the following values:

- DENY - prevents any domain from framing the content (recommended setting).
- SAMEORIGIN - whitelists current site to frame a content.
- ALLOW-FROM - whitelists some specific site to frame a content.

##### Content-Security-Policy frame-ancestors directive

Similar to X-Frame-Options headers, the frame-ancestors directive can be used in a Content-Security-Policy header to indicate whether or not a browser should be allowed to render a page inside frame/iframe element.

##### Common values of CSP frame-ancestors:

- 'none' - prevents any domain from framing the content (recommended setting).
- 'self' - whitelists current site to frame a content.
- https://mysite.com - whitelists mysite.com on port 443 (HTTPS).

X-Frame-Options headers Content-Security-Policy frame-ancestors directive have limited browser support, which makes some browsers vulnerable to the attack even with appropriate settings in place.

##### Frame Breaking Scripts

One way to defend against clickjacking is to include a "frame-breaker" script in each page that should not be framed. [Learn more](https://cheatsheetseries.owasp.org/cheatsheets/Clickjacking_Defense_Cheat_Sheet.html#best-for-now-legacy-browser-frame-breaking-script) about "frame-breaker" scripts.

The best form of protection against Clickjacking is combination of Frame Breaking scripts, X-Frame-Options Response Headers, and Content-Security-Policy frame-ancestors directive. It allows to have an adequare coverage for most modern, and legacy browsers.

---

This article is based on my [Web Security Reference](https://aakatev.github.io/web-security).