history = require('sdk/places/history')
Promise = require('sdk/core/promise')

###
# Filters feed items before display
interface Filter
  # Determines if a given item is accepted or not
  #
  # @param [FeedItem] item The item to check
  #
  # @return [Promise] A promise that is resolved with true if the item is
  # accepted, or false if it is rejected.
  isAccepted : (item)
###

# Implements a @see Filter that filters out already visited links.
class HistoryFilter # implements Filter
  isAccepted : (item) =>
    { promise, resolve, reject } = Promise.defer()
    history.search({ url: item.link }, {})
      .on('end', (results) => resolve(results.length == 0))
      .on('error', reject)
    promise

exports.HistoryFilter = HistoryFilter
