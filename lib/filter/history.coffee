history = require("sdk/places/history")
Promise = require("sdk/core/promise")

# Implements a @see Filter that filters out already visited links.
class HistoryFilter # implements Filter
  isAccepted : (item) =>
    { promise, resolve, reject } = Promise.defer()
    history.search({ url: item.link }, {})
      .on("end", (results) => resolve(results.length == 0))
      .on("error", reject)
    promise

exports.HistoryFilter = HistoryFilter
