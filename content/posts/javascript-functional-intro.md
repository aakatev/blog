---
title: "Intro to Functional JavaScript"
date: 2020-06-06T08:42:08-07:00
draft: false
tags: ["javascript", "functional", "closure"]
featured: false
description: "Functional JavaScript is fun! Learn more about folding, reducing, filtering, and also ES6 destructuring operator."
---

> This article is based on my old cheatsheet. It only includes methods provided by Vanilla JS. If you are looking for more advanced patterns, I recommend to look into [Ramda](https://ramdajs.com/). 

Do you know that out of the box JavaScript has some amazing parts, making it suitable for Functional Programming?

## Folding, Reduction, and Filtering

Let's say we have ten bank accounts.

```javascript
let accounts = [
  { id: 0, balance: 122.01 },
  { id: 1, balance: 15.111 },
  { id: 2, balance: 7703.5 },
  { id: 3, balance: 9333.2 },
  { id: 4, balance: 1472.111 },
  { id: 5, balance: 993.5 },
  { id: 6, balance: 0.222 },
  { id: 7, balance: 1599.111 },
  { id: 8, balance: 779.5 },
  { id: 9, balance: 93.2 }
];
```

To warm-up, let's find the total balance. We can do it by folding account balances using addition operator, and initial value of `0`. In JavaScript it can be accomplished using `reduce()`.

```javascript
let totalBalance = accounts.reduce(
  (sum, account) => sum + account.balance,
  0
);
```

Now, what if we need to get all the accounts with the balance of 700.00 or higher? It is done using `filter()`.

```javascript
let filteredAccounts = accounts.filter(
  (account) => account.balance > 700
);
```

What if we only need to work with account `id`s? Function `map()` is really helpful for this case! 

```javascript
let ids = accounts.map((account) => account.id);
```

We can also chain these functions, and manipulate collections in short, and elegant way. 

```javascript
accounts
  .map((account) => account.balance)
  .filter((balance) => balance < 100)
  .reduce((sum, balance) => sum + balance, 0);
```

Amazing, is not it? Now, let's see some more!

## ES6 Destructuring Operator

We have an array of ten numbers.

```javascript
let numbers = [0,1,2,3,4,5,6,7,8,9];
```

This is how we can iterate, and print them using the Tail recursion.

```javascript
function printArray(array) {
  if(array.length > 0) {
    let [head, ...tail] = array;
    console.log(head);
    printArray(tail);
  }
}
```

Using the destructuring operator, we can also create variadic functions, similar to ones in LISP.

```javascript
function variadicPrint(...array) {
  array.forEach(element => console.log(element))
}
```

All the following calls to the function above are legal.

```javascript
variadicPrint(0, 1, 2, 3);
variadicPrint(0);
variadicPrint();
variadicPrint("Hello", "world");
```

Finally, I already posted an [article about closures](https://dev.to/aakatev/counter-using-functional-approach-in-javascript-5d5h), which is probably the best part of the JavaScript.