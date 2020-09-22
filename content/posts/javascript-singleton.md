---
title: "Singleton Pattern in JavaScript"
date: 2020-04-12T08:42:08-07:00
draft: false
tags: ["javascript", "functional", "closure", "patterns"]
featured: true
description: "Functional JavaScript is fun! Learn more about module pattern and closure by implementing a singleton pattern."
---

If you come from Java or C++ background, you are probably used to classic OOP model, and it is hard to imagine how you can implement singleton in JavaScript. The answer to this question is to use closures!

It is the same idea as module patterns, and comes from functional programming. The essence of closure, is creating an inner function in a scope of an outer function. If you know JS, you know that inner function has access to data members that are in the scope of the outer function. So, as long as you preserve a reference to the inner function, you can access enclosed members of the outer function, even when the outer function finished its execution. It may take some time to get your head around this definition!

Anyway, it is often easier to show something in code than explain in natural language!

Here is an example of singleton http client, which wraps an axios library:

```javascript
let http = (function () {
  let axios = require('axios')

  return {
    get: function(url) {
      return axios.get(url)
    },
    post: function(url) {
      return axios.post(url)
    }
  }

}())
```

As you can see we create an [IIFE](https://developer.mozilla.org/en-US/docs/Glossary/IIFE), holding instance of axios client in its scope. IIFE immediately resolves to a function containing get, and post methods. This way, we not only create a singleton instance of http, but also encapsulated axios from the rest of out program. 

We still however, can access methods of axios instance using get and post functions, returned from closure:

```javascript
http
  .get('https://baconipsum.com/api/?type=all-meat&paras=1&start-with-lorem=1')
  .then((res) => console.log(res.data))
```

I know it is a lot of information for only few paragraphs of text. If you want to learn more about closures, or JS in general, I highly recommend watching [FrontendMasters course by Douglas Crockford](https://frontendmasters.com/courses/good-parts-javascript-web/). It is free for all students, under [GitHub Student Pack](https://education.github.com/pack)!