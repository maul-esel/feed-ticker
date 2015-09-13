{ Frame } = require('sdk/ui/frame')
{ Toolbar } = require('sdk/ui/toolbar')
tabs = require("sdk/tabs")

# Manages the displayed items.
# Communicates with @see View instances running in the context of the UI's frame.
class ViewManager
  # The list of items displayed in the toolbar.
  # @private
  displayedItems : []

  # Creates a new instance and initializes the UI
  constructor : ->
    @createUI()

  # Clears the list of displayed items
  # @note To have any effect on the UI, @see update() must be called after any calls ot this method.
  clear : =>
    @displayedItems = []

  # Adds a new item to be displayed or updates an existing one.
  #
  # @param [FeedItem] item The item to be displayed
  #
  # @note To have any effect on the UI, @see update() must be called after any calls ot this method.
  displayItem : (item) =>
    index = @displayedItems.findIndex((other) => other.id == item.id)
    if (index == -1)
      @displayedItems.push(item) # TODO: insert at specific position
    else
      @displayedItems[index] = item

  # Removes an item from the list of displayed items, if it exists there.
  #
  # @param [FeedItem] item The item to be removed
  #
  # @note To have any effect on the UI, @see update() must be called after any calls ot this method.
  removeItem : (item) =>
    index = @displayedItems.findIndex((other) => other.id == item.id)
    @displayedItems[index..index] = [] unless index == -1

  # Updates views with the changes made to the list of displayed items.
  #
  # @param view The view to update
  # @param origin The origin fro the view update
  #
  # @note The parameters are for internal use by this class only.
  update : (view = null, origin = null) =>
    @send('REPLACE_ITEMS', @displayedItems, view, origin)

  # Helper method to create the toolbar UI
  # @private
  createUI : =>
    @frame = Frame({
      url: './ticker.html'
      onMessage: @onReceiveMessage
    })
    toolbar = Toolbar({
      name: 'rss-ticker-nova-bar',
      title: 'RSS Ticker Toolbar',
      items: [@frame]
    })

  # Helper method for communication with the @see View instances
  # @private
  #
  # @param [String] command The command to send to the views
  # @param [String,Number,Object] data Additional data to send
  # @param view The view to update. If omitted, all views are updated.
  # @param origin The origin for the update. Used in conjunction with the previous parameter
  send : (command, data, view = null, origin = null) =>
    (view ? @frame).postMessage(JSON.stringify({
      command: command,
      data: data
    }), origin ? @frame.url)

  # Callback method for communication with the @see View instances
  # @private
  onReceiveMessage : (event) =>
    message = JSON.parse(event.data)
    switch message.command
      when 'READY'
        @onViewReady(event.source, event.origin)
      when 'NOTIFY_CLICK'
        @onNotifyClick(message.data)

  # Helper method to handle messages from a view.
  # @private
  onViewReady : (view, origin) =>
    @update(view, origin)

  # Helper method to handle messages from a view.
  # @private
  onNotifyClick : (item) =>
    @removeItem(item)
    tabs.open(item.link)
    @send('REMOVE_ITEM', item)
    # TODO: permanently remove

exports.ViewManager = ViewManager
