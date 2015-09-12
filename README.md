# Ticker – a RSS ticker add-on for Firefox

## Concept

- [x] sources provide feeds
- [x] feeds have an requestUpdate() method
- [x] feeds have an "updated" event
- [x] feeds have a "items" property (array)
- [x] a model has sources and filters
- [x] a model derives its feeds from its sources
- [ ] a model has a view
- [ ] a view has a list of displayed items
- [ ] when a feed raises its "updated" event, a listening model updates its view's displayed items

***

## Classes
- [ ] Feeds
  - [x] class Feed
  - [x] class RemoteXmlFeed : Feed (chrome for xml parsing)
  - [x] class RSSFeed : RemoteXmlFeed
  - [ ] class AtomFeed : RemoteXmlFeed
- [x] class FeedItem
- [ ] Filters
  - [x] "interface" Filter
  - [ ] class HistoryFilter : Filter
- [ ] class FaviconManager
- [ ] class Model
- [ ] class View
- [x] Sources
  - [x]  "interface" Source
  - [x] class LivemarkSource : Source (chrome for livemark iteration)

***

## Problems

- [ ] differentiate between atom and rss feeds by URL
