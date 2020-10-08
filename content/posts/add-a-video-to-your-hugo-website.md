---
title: "Add a Video to Your Hugo Website"
date: 2020-09-05T10:42:08-07:00
draft: false
tags: ["tutorial", "webdev", "hugo", "jamstack"]
featured: true
description: "Learn how to add an external video to your Hugo website using Clappr, JavaScript media player."
---

Hugo is the world’s fastest framework for building websites. It is easy to get started, and has a fair number of customization available out of the box. It is a great choice for content creators who don't want to spend a lot of time on HTML and CSS, but would rather focus on delivering their product to the audience. 

Video is one of the most common forms of the media content. Out of the box, Hugo allows for including YouTube and Vimeo resources. There is no real support for the video files hosted externally.

Today, I will show you how to overcome this issue using Hugo [shortcodes](https://gohugo.io/templates/shortcode-templates/).

First, let's define what are the shortcodes:

> Shortcodes are means to consolidate templating into small, reusable snippets that you can embed directly inside of your content.

To create a new shortcode, place its template in the `layouts/shortcodes`. In my case, I created the following template at `layouts/shortcodes/video.html`

```html
<div class="container">
  <div id="player-wrapper" class="{{ .Get 1 }}"></div>
</div>

<script 
  type="text/javascript" 
  src="https://cdn.jsdelivr.net/npm/@clappr/player@latest/dist/clappr.min.js"
>
</script>

<script>
  var playerElement = document.getElementById("player-wrapper");

  var player = new Clappr.Player({
    source: {{ .Get 0 }},
    mute: true,
    height: 360,
    width: 640
  });
  
  player.attachTo(playerElement);  
</script>
```

Directives `{{ .Get 0 }}` and `{{ .Get 1 }}` will instruct Hugo to inject the first and second arguments of the shorthand into appropriate locations. I used [Clappr](https://github.com/clappr/clappr) as a media player, but you are free to use any of the other JavaScript players available. The overall flow remains the same.

Now, I can create a new Markdown document, and use the newly created shorthand. Two arguments has to be provided: link to the video, and CSS class to apply to the container wrapping the video element. 

```md
---
title: 'Hello Video'
date: 2020-09-20T19:02:50-07:00
draft: false
---

Look what I can do!

{{</* video "http://clappr.io/highline.mp4" "my-5" */>}}
``` 

That's it! If you weren't able to follow along, the [source code is available on my GitHub](https://github.com/aakatev/hugo-video-starter). For the example of the final result follow [this link](https://aakatev.github.io/hugo-video-starter/example/).