---
title: "Multipage Application with Node and Webpack"
date: 2020-04-04T08:42:08-07:00
draft: false
tags: ["javascript", "node", "webpack", "boilerplate"]
featured: false
description: "Webpack is the greatest bundler for the web. Learn how to use it together with Express, and combine server templating with frameworks like React or Vue."
---

## A quick tutorial on how to configure Webpack with multiple outputs.

Building Web Applications with Node is easy! There is a great number of frameworks, and tools that help programmer to bootstrap an environment and start working in just a matter of seconds. Some of them generate a bunch of boilerplate, like Create React App, while others help to eliminate it, like Gatsby. In one case, you might have a setup that you might not necessary want, in another, you are bound to certain conventions. Moreover, developers often want to have their React, Angula, Vue (insert your favorite UI library) front ends served from Express, Koa, Hapi (insert your favorite server side library). One approach is to use client side routing library, which adds more complexity to your application when implementing certain features, like authentication.

In this tutorial, I will show you how to create a basic setup for server side routing. I am going to use Express, and Preact, but the overall workflow is similar no matter the framework. The complete code of this tutorial can be found [here](https://github.com/aakatev/express-webpack-template), on GitHub. That said, I hope you will follow along instead of just jumping straight to the solution!
Alrighty, let’s begin! The easiest way to start with Express application is express-generator. We can use bare bone express app, but I want to show how you can combine Express template engine with front end UI library. For this tutorial I will use Pug aka Jade. So, let’s boostrap a new Express application:

```bash
npx express-generator --pug --git express-webpack-template
```

Once generator did it work, we can `cd`(or `dir` if you are on command prompt) into application folder. Next step is to install all the dependencies:

```bash
cd express-webpack-template
npm i
```

If you look at the project structure, it looks the following way:

```bash
├── bin
│   └── www
├── public
│   ├── images
│   ├── javascripts
│   └── stylesheets
│       └── style.css
├── routes
│   ├── index.js
│   └── users.js
├── views
│   ├── error.pug
│   ├── index.pug
│   └── layout.pug
├── app.js
├── package.json
└── package-lock.json
```

Let’s move on to installing all the development dependencies:

```bash
npm i -D webpack webpack-cli nodemon
```

For those who are not familiar, Webpack is a tool for bundling JavaScript, and Nodemon is an utility to restart Node process if changes in source code where detected.

To further simplify the workflow, I recommend to add the following scripts to your `package.json` file:

```json
...
"scripts": {
  "start": "node ./bin/www",
  "start:dev": "nodemon ./bin/www",
  "build": "webpack --config webpack.config.js",
  "build:dev": "webpack --config webpack.config.js -w"
},
...
```

Now let’s start our application for the first time!

```bash
npm run start:dev
```

Now, open your browser on `localhost:3000`, and woah!

![Alt Text](https://dev-to-uploads.s3.amazonaws.com/i/uyemznlcvtva1q32ay75.png)

Let’s add some interactivity! Since the main purpose of this tutorial is to show Webpack configuration for multiple bundles, we need to create more pages! Express-generator created two separate routers: `index.js` and `users.js`. Let’s change `users.js` router to look the following way:

```javascript
// routes/users.js
var express = require('express');
var router = express.Router();

/* GET users listing. */
router.get('/', function(req, res, next) {
  res.render('users', { title: 'Users' });
});

module.exports = router;
```

Now, express know that we need to render users.pug template on `/users` route. Let’s create this template in views folder. It might look like this:

```pug
// views/users.pug
extends layout
block content
  h1= title
  p Welcome to #{title}
  a(href='/') Go to home page
```

Also, add a tag with `href` property to `index.pug`, to go back and forth between pages.

Let’s add some front end libraries! As stated previously, I am going to install Preact! I will pair it with HTM. This way, we don’t have to waste time installing Babel, and tutorial will only be focused on bundling for server side routing. That said, the principle itself applies to more complex setups either.

```bash
npm i preact htm
```

If you have never used HTM, it is template language similar to JSX, used by React, but it is plain JS.

Anyway, let’s create create 3 JavaScript components files in `public/javascripts`:

```javascript
// public/javascripts/index.js
import { h, Component, render } from 'preact';
import { html } from 'htm/preact';
import { Navbar } from './shared';

class IndexPage extends Component {
  render() {
    return html`
      <${Navbar}/>
      <div class="container">
        <div class="notification">
          <h3 class="title">Welcome to Home Page!</h3>
          <p class="subtitle">This application uses Express and Webpack!</p>
          <div class="buttons">
            <a class="button is-link is-light" href="/users">See Users</a>
          </div>
        </div>
      </div>
    `;
  }
}
render(html`<${IndexPage}/>`, document.getElementById('app'));
```

```javascript
// public/javascripts/users.js
import { h, Component, render } from 'preact';
import { html } from 'htm/preact';
import { Navbar } from './shared';

class UsersPage extends Component {
  addUser() {
    const { users = [] } = this.state;
    this.setState({ users: users.concat(`User ${users.length}`) });
  }
  render({ page }, { users = [] }) {
    return html`
      <${Navbar}/>
      <div class="container">
        <div class="notification">
          <h3 class="title">Welcome to Users page!</h3>
          <p class="subtitle">Click a button to add more users!</p>
          <ul>
            ${users.map(user => html`
              <li>${user}</li>
            `)}
          </ul>
          <div class="buttons">
            <button 
              class="button is-success" 
              onClick=${() => this.addUser()}>
                Add User
            </button>
            <a class="button is-link is-light" href="/">Go back Home</a>
          </div>
        </div>        
      </div>
    `;
  }
}

render(html`<${UsersPage} />`, document.getElementById('app'));
```

```javascript
// public/javascripts/shared.js
import { html } from 'htm/preact';

const Navbar = () => html`
<nav class="navbar is-success" role="navigation" aria-label="main navigation">
  <div class="navbar-brand">
    <a class="navbar-item" href="https://bulma.io">
      Webpack Express Template
    </a>
  </div>
</nav>`;

export {
  Navbar
}
```

Now, let’s get to the main part! We need to bundle this Javascript, and only ship it on respective route! If you noticed earlier we provided a `webpack.config.js` file to the Webpack script in `package.json`. Let’s go ahead and create this file. Bare minimum for bundling multipage project is going to look like that:

```javascript
webpack.config.js
const path = require('path'); 
module.exports = {  
  entry: {    
    index: './public/javascripts/index.js',    
    users: './public/javascripts/users.js',    
  },  
  output: {     
    path: path.resolve(__dirname, 'public/javascripts'),
    filename: '[name].bundle.js'  
  }
};
```

Notice, how we use `[name].bundle.js` as output filename. It tells react to create two files: `index.bundle.js` and `users.bundle.js`. The only thing we have left now, is to add `div` element with propert `id="app"` in our pug templates, so that Preact can bind to it.

I also added some other `meta`tags, as well as Bulma import in layout template, so it would look a bit prettier. That’s what we have at this point:

```pug
// views/layout.pug
extends layout

block content
  div(id="app")
  script(src='javascripts/users.bundle.js')
```

```pug
// views/index.pug
extends layout

block content
  div(id="app")
  script(src='javascripts/index.bundle.js')
```

```pug
// views/users.pug
extends layout

block content
  div(id="app")
  script(src='javascripts/users.bundle.js')
```

Finally, let’s run Webpack, and bundle JavaScript!


```bash
npm run build
```

If you killed your express server, it is time to restart it! Once again, open up your browser on `localhost:3000`. Your application should be looking similar to [this one](https://webpack-express.herokuapp.com/):

![Alt Text](https://dev-to-uploads.s3.amazonaws.com/i/rxx22edzuulpvytw4rx6.png)

One last thing, when developing, it is useful to use -w flag, which tells Webpack to automatically bundle scripts on any change.

That’s it! You configured your Webpack to build assets into multiple files! If you got lost at any point, again, all source code is available on [my GitHub](https://github.com/aakatev/express-webpack-template).
