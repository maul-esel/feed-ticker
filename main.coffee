{ FeedTicker } = require('lib/feed_ticker')
{ LivemarkSource } = require('lib/source/livemarks')
{ HistoryFilter } = require('lib/filter')

m = new FeedTicker(
  [ new LivemarkSource ],
  [ new HistoryFilter ]
)
