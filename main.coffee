{ FeedTicker } = require('lib/feed_ticker')
{ LivemarkSource } = require('lib/source')
{ HistoryFilter } = require('lib/filter')

m = new FeedTicker(
  [ new LivemarkSource ],
  [ new HistoryFilter ]
)
