history = require("sdk/places/history")

# Implements a @see Filter that filters out already visited links.
class HistoryFilter # implements Filter
  filter : (item, accept, reject) =>
    history.search({ url: item.link }, {})
      .on("end", (results) =>
        if (results.length == 0)
          accept(item)
        else
          reject(item)
      )

exports.HistoryFilter = HistoryFilter
