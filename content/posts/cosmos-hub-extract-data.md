---
title: "Getting Data from Cosmos Hub using Node JS"
date: 2020-04-10T08:42:08-07:00
draft: false
tags: ["cosmos-sdk", "blockchain", "javascript", "node"]
featured: false
description: "Learn how-to extract a large amount of data from your Cosmos Hub node through the RPC interface. We will use NodeJs and RPC interface."
---

In my opinion Cosmos SDK is a really interesting project. My favorite part of their development is IBC. I like the idea of having a protocol for different Blockchains to exchange data in secure and consistent manner. I also like how Tendermint and Cosmos developers find inspiration in the way Internet was implemented. It is one of the topics that excites me either. It is so fascinating how we created all these layers of abstraction and encapsulation, in order to transport data from one physical point to another.

As a developer myself, I have worked on several project related to Cosmos. Some of them required extracting data from the network. Although Gaia Client implements REST, there are some small nuances I have found that simplified my day to day workflow.

First of all, if you are going to interact with Cosmos using REST, this is your number one [resource](https://cosmos.network/rpc/). This reference gives you the most updated information on all the available endpoints, and query or url parameters.

You can use any http client, like axios, since it is REST. Most of the stuff is pretty straightforward until you come to a point, where you want to scrape large amounts of data, and map it. Let's say I want to get all the information on all validators, including their delegations, and rewards. There is no single endpoint that can get you that. In other words, you will have to make at least multiple requests. To be concrete, you will have to do 3 requests to get bonded, unbonded, and unbonding validators. Then, we want need 2 requests per validator to get delegations, and unbonding delegations. Finally, 2 more per each to get rewards, and outstanding rewards. 

This is pretty essential information for someone building a Cosmos explorer. That said, it is not even complete. The point is, you will have to make a big number of requests. Considering asynchronous nature of Node JS, it becomes really easy to overflow your Cosmos node with requests! As a solution here, we can limit a number of maximum concurrent connections.

I will give an example using axios, but imagine most http client libraries can be configured in similar manner:

```javascript
const http = require('http')
const https = require('https')
const axios = require('axios')
const MAX_CONCURRENT = 5

const httpAgent = new http.Agent({
  maxSockets: MAX_CONCURRENT,
})
const httpsAgent = new https.Agent({
  maxSockets: MAX_CONCURRENT,
})

const client = axios.create({
  httpAgent,
  httpsAgent,
})
```

Notice, we are configuring both http, and https agents before passing then to axios.create(). It is really important in setting, where you might have separate protocols in development and production environments.

Another issue that might occur, are failing requests. Sometimes, certain validator might not have any delegations, or for whatever reason the endpoint returned you 404. In most cases, simply catching the error is not enough! Remember, the next step after getting the data, is mapping it all together! In this case, you want to have some reliable indicator to differentiate cases where data is not available, from cases where result actually arrived empty. One way to do it, is to use response interceptors. 

Again, I am going to show an example using Axios, but it could be applied to any other http client library.

```javascript
const axios = require('axios')

const client = axios.create()

client.interceptors.response.use(
  function (response) {
    return response.data.result
  },
  function (error) {
    console.log(error)
    return {
      data: {
        result: null,
      },
    }
  }
)
```

Notice, how we are handling not only cases of failure, but also success. This is an easy way to predictably structure data, and decreasing chance of runtime errors on processing step. 

Of course, all of the tips are applicable to other cases when you might want to extract massive amount of data using Node JS, but they are essential when working with Cosmos. 

Final words, I created a tiny library that implements all of this best practices mentioned here, as well as wraps Cosmos endpoints with minimal promise-based layer. The library is available on [GitHub](https://github.com/cyphercore-dev/cosmos-service), and is fully open source and free to use. It is still work in progress, but most of its implemented interface is going to remain the same. It is highly minimalistic and should be viewed as a tool to build other libraries, or services using JS, and Node JS.