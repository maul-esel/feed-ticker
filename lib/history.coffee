{ Cc, Ci } = require('chrome')
Promise = require('sdk/core/promise')

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

# Tests if a URL has been visited before
# This method works asynchronously.
#
# @param url [String] The URL to test
#
# @return [Promise] A promise that is resolved with the result of the check
isVisited = (url) ->
  { promise, resolve, reject } = Promise.defer()
  asyncHistory.isURIVisited(ioService.newURI(url, null, null),
    isVisited: (uri, visited) -> resolve(visited)
  )
  promise

exports.markVisited = markVisited
exports.isVisited = isVisited
