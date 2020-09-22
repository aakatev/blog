---
title: "Three.JS-Webpack Boilerplate"
date: 2020-04-21T08:42:08-07:00
draft: false
tags: ["javascript", "node", "webpack", "boilerplate"]
featured: false
description: "Three.Js is an awesome library. I created this boilerplate with Webpack so you can jump straight into building your project, rather than configuring the build tool."
---

## Overview

[Three.JS](https://threejs.org/) is an awesome library. It is based on WebGL, and has a straightforward, and well-documented API. However, I found that project's initial setup may require some boilerplate.

I created some minimal configuration to bootstrap a project, and want to share with everyone. It includes [webpack](https://github.com/webpack/webpack), [webpack-dev-server](https://github.com/webpack/webpack-dev-server), and [prettier](https://github.com/prettier/prettier). I also included one of three.js demo projects, to test deployment on GitHub pages.

The boilerplate is available on [GitHub](https://github.com/aakatev/three-js-webpack), and you can play with the demo [here](https://aakatev.github.io/three-js-webpack/).

## Instructions

### Development

Clone the project, and install dependencies

```bash
git clone https://github.com/aakatev/three-js-webpack.git
npm i
```

Run webpack-dev-server

```bash
npm run start
```

### Deployment

(Optional) Format your code

```bash
npm run format
```

Bundle javascript

```bash
npm run build
```

Upload on any static website hosting, like GitHub pages! Done!