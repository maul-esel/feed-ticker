{ Request } = require('sdk/request')
Promise = require('sdk/core/promise')

xml = require('lib/markup')
feedparser = require('lib/parser')
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

  # @property ID [String] A unique ID identifying the feed instance globally
  ID
###

# A class for feeds based on XML documents available on the web
class RemoteXmlFeed extends CommonBase # implements Feed
  items : []

  # Creates a new instance of this class.
  #
  # @param [String] url The URL where the XML document can be found
  constructor : (@url) ->

  @property 'ID',
    get: -> "__feed_#{@url}__#{@constructor.name}_#{@__instance_number__}__"

  update : =>
    { promise, resolve, reject } = Promise.defer()
    Request(
      url: @url
      onComplete: (response) =>
        try
          @onDocumentReceived(response)
          resolve()
        catch error then reject(error)
    ).get()
    promise

  # Callback for requests to the URL
  # @private
  onDocumentReceived : (response) =>
    throw "request failed" unless 200 <= response.status < 300
    @items = feedparser.parse(this.ID, xml.parse(response.text))

exports.RemoteXmlFeed = RemoteXmlFeed
