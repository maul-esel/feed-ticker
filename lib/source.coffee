###
# Provides a source of feeds
interface Source
  # Gets the @see Feed instances for this source
  #
  # @return [Feed[]] the feeds provided by this source
  getFeeds : ()
###
