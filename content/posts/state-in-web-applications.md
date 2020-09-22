---
title: "The Problem of Centralized State in Web Applications"
date: 2020-05-21T08:42:08-07:00
draft: false
tags: ["research", "state", "design"]
featured: false
description: "An approach on how to synchronize state in a typical web application illustrated using HTTP and WebSocket protocols."
---

## Intro

For one of my senior classes this year, I worked on a project where we were building an online game. As you can imagine, the main issue becomes a question of keeping players in sync with the most recent game state. There are tons of solutions allowing to organize your state in browser, such as Redux, Mobx, or Ngrx. However, the tricky part is to synchronize state between multiple clients, and centralized storage, such as database. It is not only multiplayer games where developers encounter the problem, but many other web applications requiring experience to be so-called "live". 

## Proposed Solution

In this article, I will share an approach we used to solve the problem of centralized state illustrated using an example of an online chat application. For code snippets, I will use pseudo-code, which is similar to JavaScript. Protocols used are HTTP, and WS. That said, the article is meant to be language, and protocol agnostic. You can use other technologies for the actual implementation.

## Components

#### Chat Client

If you have ever used React, Angular, or Vue, you can think of this client as a component lacking presentation logic. 

```javascript
class Chat {
  messages = []
  ws.on(MESSAGE_EVENT => this.getMessages)
  
  setMessages(newMessages) { 
    this.messages = newMessages 
  }  
  
  getMessages() { 
    http.get(`/chat/${id}`)
      .then(this.setMessages).catch(displayError) 
  }
  
  sendMessage(message) { 
    http.post('/chat/${id}', message).catch(displayError) 
  }
}
```

The client's local state is an array of messages. The component contains logic to update the messages using Chat API through HTTP. On successful update, the messages are set to a new value. The old state of the messages is not important. You will see later why. The interesting part, is the method for sending messages. We don't handle its successful outcome. Why? To answer, this question let's look at the API code.

#### Chat API

If you are familiar with NodeJS framework Express, this pseudo-code will be easy to read. We have two HTTP endpoints.

```javascript
router.get('/chat/:id', (request, response) => {
  db.getMessagesByChatId(request.params.id)
    .then(response.json)
    .catch(response.json)
})

router.post('/chat/:id', (request, response) => {
  db.addMessage(request.params.id, 
                request.body.message)
    .then(() => {
      response.json({ error: undefined })
      ws.emit(MESSAGE_EVENT)
    })
    .catch(response.json)
})
```

The first one, GET route, is responsible for lookup to database, and returning the result. The POST route is the most interesting to us. It updates the database with new message, and on success, returns to the client an empty json. However, right after the response is resolved, the server also broadcasts MESSAGE_EVENT to all the subscribers.

Going back to the client code, it contains a WS client instance, listening for the same MESSAGE_EVENT. Once received, the event would trigger a local state update. Notice, the WS message does not have any payload. Its sole purpose is to inform a client about the changes in the database state. The client itself is responsible for getting the updated state.

## Application Flow

Now, same steps but visualized. I put protocols where it is appropriate. I did not include a protocol for the database connection, since it is irrelevant. Note, that arrows indicate the flow of the payload that affect or contain the application's global state. 

#### 1. Client creates an actions

![Alt Text](https://dev-to-uploads.s3.amazonaws.com/i/mo7oz8vyboc94nlad5py.png)

In our case, it is a new message. The protocol used is HTTP. The server commits a change to the database. Client receives response without any payload. The message was sent.

#### 2. Server broadcast an event

![Alt Text](https://dev-to-uploads.s3.amazonaws.com/i/vlv56vd36czlu3bxth60.png)

The change is committed. Next step, the server broadcast the event about the new message to all the subscribers. In this case, using WS protocol. In this step, the clients again do not receive any payload. 

#### 3. Clients synchronize the state 

![Alt Text](https://dev-to-uploads.s3.amazonaws.com/i/ku3q0j05fibhe4sm263n.png)

The subscribed clients, triggered by the new message event, update their local states using HTTP. The updated state is transmitted in this step.

## Pros and Cons

This approach is relatively straightforward to implement. Especially in the most simple form, illustrated in this article. The biggest advantage, you don't have to care about a local state of your client at some particular time. You can even have a client who missed several messages catching up with the rest without implementing any extra logic. 

The main drawback, this approach as presented, is not the most efficient one. You always send the whole state, which, depending on its size, can be rather wasteful. Extended logic is required to improve the efficiency. Presentation logic for the client component is out of scope of this article. That said, it is something that would also require you to either implement caching, or similar technique. Using a UI library would also be a solution.

## Conclusion

In this article, I demonstrated how to keep web clients synchronized with a centralized state. I used an example of online chat app, but the proposed solution is application agnostic. The article only solves problem on a high level, and most of the implementation details are left up to a developer.