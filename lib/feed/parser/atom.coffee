{ XPathResult } = require('lib/markup')
{ FeedItem } = require('lib/feed_item')

# Implements a parser for Atom feeds
class AtomParser
  NS_ATOM = 'http://www.w3.org/2005/Atom'

  canParse: (doc) =>
    doc.documentElement.namespaceURI == 'http://www.w3.org/2005/Atom'

  parse: (doc) =>
    link_rels = ['not(@rel)', '@rel="alternate"', '@rel="self"']
    entries = doc.evaluate('/atom:feed/atom:entry', doc, @constructor.nsResolver, XPathResult.ANY_TYPE, null)
    while (entry = entries.iterateNext())?
      new FeedItem(
        title   : @getString(entry, 'atom:title/text()')
        link    : (link for rel in link_rels when (link = @getString(entry, "atom:link[#{rel}]/@href")) != '')[0]
        id      : @getString(entry, 'atom:id/text()')
        date    : @getString(entry, 'atom:updated/text()') # TODO: parse
        summary : @getString(entry, 'atom:summary/text()')
      )

  getString : (context, xpath) =>
    context.ownerDocument
      .evaluate(xpath, context, @constructor.nsResolver, XPathResult.STRING_TYPE, null)
      .stringValue

  @nsResolver: (prefix) =>
    NS_ATOM if prefix == 'atom'

exports.AtomParser = AtomParser
