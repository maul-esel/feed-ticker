history = require('lib/history')

###
# Filters feed items before display
interface Filter
  # Determines if a given item is accepted or not
  #
  # @param item [FeedItem] The item to check
  #
  # @return [Promise] A promise that is resolved with true if the item is
  # accepted, or false if it is rejected.
  isAccepted : (item)
###

###
Implements a {Filter} that filters out already visited links.
###
class HistoryFilter # implements Filter
  isAccepted : (item) =>
    history.isVisited(item.link).then((visited) -> !visited)

exports.HistoryFilter = HistoryFilter
