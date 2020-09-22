---
title: "Counter Using Functional Approach in Javascript"
date: 2020-04-16T08:42:08-07:00
draft: false
tags: ["javascript", "functional", "introduction"]
featured: false
description: "Functional JavaScript is fun! Learn closure by building and using a simple counter."
---

In my previous post, I showed my readers [how to implement Singleton in JavaScript](https://dev.to/aakatev/singleton-pattern-in-javascript-31gd) using [closure](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Closures), and [IIFE](https://developer.mozilla.org/en-US/docs/Glossary/IIFE).

This time, I want to show you how to utilize the same building blocks, as well as one more functional programming technique, to implement a basic counter!

Let's start with a counter that takes a starting number as an argument, and uses closure to keep track of the current count:

```javascript
function from(start) {
  let i = start - 1

  function inc() {
    i = i + 1 
    return i
  } 
  return inc 
}
```

As you can see, I have outer function `from()` which takes parameter `start`. Then, I initialize `i`  with the value of `start - 1`, and enclose it in inner function `inc()`. Every time `inc()` is executed, it increases `i`, and returns it. Finally, the inner function is returned from the outer. 

Now, let's see how to use this counter:


```javascript
(function () {
  let count = from(0)

  for(let i = 0; i < 10; i++) {
    console.log(
      count()
    )
  }
}())
```

I wrapped the counter in anonymous IIFE, just because it is a good practice to separate variables from global scope, even when doing something as simple as this example.

Notice, how closure allows this counter to have a "memory". Similar technique can be utilized in order to implement [memoization](https://en.wikipedia.org/wiki/Memoization) in more advanced and computationally heavy algorithms.

Another thing I want to show you is a concept of higher-order functions. It is exactly what it sounds like:

> In mathematics and computer science, a higher-order function is a function that does at least one of the following: takes one or more functions as arguments, returns a function as its result.

Actually, if you think about it, our function `from` already fall under definition of the higher-order function. It returns another function, `inc`. Let's make something that satisfy both properties of the definition!

I will build a counter that starts counting from a given value, but doesn't count past certain limit. Past the limit, it returns `undefined`. I have the counting logic written in the example above, and only need to handle the limit part. A good approach is to create a function `to` that takes two arguments: a counter, and a limit. It then returns another function, that calls a counter, and makes sure the limit is not reached. Here is an implementation:

```javascript
function to(counter, limit) {
  return function() {
    let j = counter();
    if(j > limit) {
      return undefined 
    }
    return j
  }
}
```

Notice, that in the example I am returning an anonymous function. I actually did it on purpose, in order to show a reader that JavaScript is pretty flexible in this extend. You can as well use an arrow function. It is all up to your particular implementation!

Finally, I will include an example of the whole program:

```javascript
function from(start) {
  let i = start - 1

  function inc() {
    i = i + 1 
    return i
  } 
  return inc 
}


function to(counter, limit) {
  return function() {
    let j = counter();
    if(j > limit) {
      return undefined 
    }
    return j
  }
}


(function (){
  let count = to(from(3), 10);
  
  for(let i = 0; i < 10; i++) {
    console.log(
      count()
    )
  }
}())
```

To sum up, I showed a reader how to use closure in order to implement a simple counter, and introduced a notion of higher-order function. Also, I gave a hint on how to implement memoization using approach from this example! If you have any questions, let me know in comments!

Happy hacking!