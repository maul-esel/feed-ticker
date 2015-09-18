{ Request } = require('sdk/request')
Promise = require('sdk/core/promise')
{ Ci, Cc } = require('chrome')

{ FeedItem } = require('lib/feed_item')
{ CommonBase } = require('lib/common_base')

###
# Represents a feed of items to display
interface Feed
  # The list of currently known items
  items : []

  # Updates the feed content
  #
  # @return [Promise] A promise that is resolved once the update is complete, or rejected in case of error.
  update : ()

  # @property [String] A unique ID identifying the feed instance globally
  ID
###

###
Handles atom and RSS feeds using firefox' internal feed API
###
class AtomRssFeed extends CommonBase # implements Feed
  items : []

  ###
  Creates a new instance of this class.

  @param url [String] The URL where the XML document can be found
  ###
  constructor : (@url) ->

  @property 'ID',
    get: -> "__feed_#{@url}__#{@constructor.name}_#{@__instance_number__}__"

  update : =>
    { promise, resolve, reject } = Promise.defer()
    Request(
      url: @url
      onComplete: (response) => @onDocumentReceived(response, resolve, reject)
    ).get()
    promise

  ###
  Callback for requests to the URL
  @private
  ###
  onDocumentReceived : (response, resolve, reject) =>
    unless 200 <= response.status < 300
      reject('request failed')
      return

    try
      parser = Cc['@mozilla.org/feed-processor;1'].createInstance(Ci.nsIFeedProcessor)
      parser.listener = {
        handleResult: (result) =>
          try
            @onFeedParsed(result)
            resolve()
          catch e then reject(e)
      }
      parser.parseFromString(response.text, @constructor.createURI(@url))
    catch e
      reject(e)

  ###
  Callback for the feed parsing API
  @private
  ###
  onFeedParsed : (result) =>
    enumerator = result.doc.QueryInterface(Ci.nsIFeed).items.enumerate()
    @items = while enumerator.hasMoreElements()
      item = enumerator.getNext().QueryInterface(Ci.nsIFeedEntry)
      new FeedItem(@ID,
        title:   item.title.plainText()
        link:    item.link.spec
        id:      item.id
        date:    new Date(item.updated)
        summary: item.summary.text
      )

  ###
  Helper method to create nsIURI instances from strings
  @private
  ###
  @createURI : (url) =>
    @ioService ?= Cc['@mozilla.org/network/io-service;1'].getService(Ci.nsIIOService)
    @ioService.newURI(url, null, null)

exports.AtomRssFeed = AtomRssFeed
