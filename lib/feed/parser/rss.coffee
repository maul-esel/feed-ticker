{ XPathResult } = require('lib/markup')
{ FeedItem } = require('lib/feed_item')

# Implements a parser for RSS documents
class RssParser # implements Parser
  canParse : (doc) =>
    doc.documentElement.tagName == 'rss'

  parse : (doc) =>
    entries = doc.evaluate('/rss/channel/item', doc, null, XPathResult.ANY_TYPE, null)
    while (entry = entries.iterateNext())?
      new FeedItem(
        title   : @getString(entry, 'title/text()')
        link    : @getString(entry, 'link/text()')
        id      : @getString(entry, 'guid/text()')
        date    : @getString(entry, 'pubDate/text()') # TODO: parse
        summary : @getString(entry, 'description/text()')
      )

  getString : (context, xpath) =>
    context.ownerDocument
      .evaluate(xpath, context, null, XPathResult.STRING_TYPE, null)
      .stringValue

exports.RssParser = RssParser
