{ Cc, Ci } = require('chrome')

ioService = Cc['@mozilla.org/network/io-service;1'].getService(Ci.nsIIOService)
asyncHistory = Cc['@mozilla.org/browser/history;1'].getService(Ci.mozIAsyncHistory)

# Marks a URL as visited.
# This method works asynchronously.
#
# @param url [String] The URL to insert into browser history
markVisited = (url) ->
  asyncHistory.updatePlaces(
    uri: ioService.newURI(url, null, null)
    visits: [
      transitionType: Ci.nsINavHistoryService.TRANSITION_LINK
      visitDate: Date.now() * 1000
    ]
  )

exports.markVisited = markVisited
