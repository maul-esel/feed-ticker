---
title: FeedTicker News
css: ['news']
---

{% for post in site.posts %}
## [{{ post.title }}]({{ site.baseurl }}{{ post.url }})
{{ post.excerpt }}
{% endfor %}
