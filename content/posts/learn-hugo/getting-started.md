---
title: "[Learn Hugo] Getting Started with Static Websites"
date: 2020-09-05T10:42:08-09:00
draft: false
tags: ["tutorial", "webdeb", "learn-hugo", "hugo", "jamstack"]
featured: false
description: "Welcome to the first tutorial in Learn Hugo series. We will talk about differences between static and dynamic websites, and why do you need want to use a static site generator."
---

I have published a number of posts featuring Hugo. They got the least number of views and responses I have ever had on `dev.to`. Considering this fact, I don't know why I decided it would be a good idea to have the whole series of articles dedicated to "the world’s fastest framework for building websites".

The format for the series is going to be beginner friendly. Each post covers a single feature, or some subset of a feature. It is assumed the reader have familiarity with HTML and CSS. Prior JavaScript experience is definitely beneficial, but it is not a hard requirement.

## Static vs. Dynamic Websites

Why use Hugo? This question can be rephrased as "why use a static site generator". To answer it, we need to understand the difference between static and dynamic websites.

Any website that requires a processing before sending user HTML, JavaScript, or CSS is dynamic. For example, a server constructing HTML, or making a database request. In a static websites world, the processing is done beforehand. The browser receives the site in the exact same form it is hosted on the server. Some benefits of using static websites are reduced complexity, increased security, easier to version control, and faster to deploy.

![Alt Text](https://dev-to-uploads.s3.amazonaws.com/i/tilafl0nsp38kaly7liw.jpg)

Not every website has to be dynamic. Blogs, documentations, newspaper websites, photo and video galleries, portfolios, company sites are all static in nature. Instead of storing posts, pictures, or videos in a database or storage server, the content can be injected in the HTML before we deploy the website. This procedure is called prerendering. The processed HTML can be stored on any file server, or content delivery network (CDN).

## Hugo and Competitors

Hugo is not the only static site generator. There are many well known alternatives. Gatsby, Next, Jekyll. The first two are built on top of React, and give developers the benefits of having JavaScript ecosystem. The downside is complexity. Jekyll is written in Ruby, and is not nearly as complex as its JavaScript competitors. It has been around for sometime, and has many great "getting started" resources available online.  

Prerendering HTML is one of the main purposes of a static website generator. This is where Hugo really shines. It is extremely fast! The build times for both development and production rarely exceed few seconds. The speed and simplicity is what makes Hugo an excellent choice for building a static website. 

## Installation

Hugo is written in Go, and ships as a single binary. Below are the commands to install it using the most popular package managers:

**Homebrew**

```sh
brew install hugo
```

**Chocolatey**

```sh
choco install hugo -confirm
```

**Apt**

```sh
sudo apt-get install hugo
```

Some other methods to obtain the binary, including build it from source, are described in the [Hugo official docs](https://gohugo.io/getting-started/installing/).

## Hello World in Hugo

It is finally time to create our first website! 

Open your terminal and run:

```sh
hugo new site hello-world
```

You should see something similar to `Congratulations! Your new Hugo site is created`. You will also see a message telling you how to create a theme, and generate content. We will skip all of these suggestions, and focus on the generated project's structure.

The `hello-world` folder looks the following way:

```sh
├── archetypes
│   └── default.md
├── config.toml
├── content
├── data
├── layouts
├── static
└── themes
```

This is a skeleton of a typical Hugo project. In the future articles we will cover each section in more details. For now, let's move on and start developing. 

Go back to the terminal and run:

```sh
hugo server -p 3000
```

It will start the development server on port `3000`. If you don't provide `p` flag, the server will start on the port `1313`. You might see few warning in your terminal. It is safe to ignore them for the time being.

The server is running. However, if you open your browser on [`http://localhost:3000`](http://localhost:3000/) you won't see anything rather than an empty page. 

**Don't panic!** Hugo is one of the frameworks that doesn't make any assumptions about your project. Therefore, you get nothing out of the box.

Let's create a new file at `layouts/index.html`, with the following content:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>{{ .Title }}</title>
    <link rel="stylesheet" href="style.css">
    <script src="script.js"></script>
  </head>
  <body>
    <h3>Hello World</h3>
  </body>
</html>
```

The server should automatically pickup the newly created file. Navigate back to your browser. You should see the following page:

![Alt Text](https://dev-to-uploads.s3.amazonaws.com/i/fndkw3ur803kwozn0qtu.png)

That's it for now! Next time we'll get back to the Hugo project's structure, and talk more about each of the generated directories. In this series, we'll also cover templates, content management, and many other topics. Stay tuned!