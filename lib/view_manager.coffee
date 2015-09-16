{ Frame } = require('sdk/ui/frame')
{ Toolbar } = require('sdk/ui/toolbar')
{ Panel } = require('sdk/panel')
tabs = require('sdk/tabs')
preferences = require('sdk/simple-prefs').prefs
windowUtils = require('sdk/window/utils')
{ identify } = require('sdk/ui/id')

{ Templater } = require('lib/templater')
{ Menu, MenuItem, SubMenu } = require('lib/menu')

# Manages the displayed items.
# Communicates with @see View instances running in the context of the UI's frame.
class ViewManager
  # The list of items displayed in the toolbar.
  # @private
  displayedItems : []

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
    if @displayedItems.length == 0 && preferences.hideOnEmpty
      @hideToolbar()
    else
      @showToolbar()
      @send('REPLACE_ITEMS', @displayedItems, view, origin)

  hideToolbar : =>
    if @toolbar?
      @toolbar.destroy()
      @toolbar = undefined

  showToolbar : =>
    @toolbar = Toolbar({
      name: 'feed-ticker-toolbar',
      title: 'Feed Ticker Toolbar',
      items: [@frame],
      onAttach: => @menu.contextMenu('inner-' + identify(@toolbar))
    }) unless @toolbar?

  # Helper method to create the toolbar UI
  # @private
  createUI : =>
    @frame = Frame({
      url: './ticker.html'
      onMessage: @onReceiveMessage
    })
    @itemSpecific = []
    @menu = new Menu([
      new MenuItem('Refresh feeds'),
      Menu.Separator,
      @itemSpecific[...0] = new MenuItem('Open feed in tabs', { disabled: true }),
      new MenuItem('Open all in tabs'),
      Menu.Separator,
      @itemSpecific[...0] = new MenuItem('Mark as read', { disabled: true }),
      @itemSpecific[...0] = new MenuItem('Mark feed as read', { disabled: true }),
      new MenuItem('Mark all as read')
    ], { onHide: @resetMenu })

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
      when 'SHOW_DETAILS'
        @onShowDetails(message.data.item, message.data.left)
      when 'HIDE_DETAILS'
        @onHideDetails()
      when 'CONTEXT_MENU'
        @onItemContextMenu(message.data)

  # Helper method to handle messages from a view.
  # @private
  onViewReady : (view, origin) =>
    @update(view, origin)

  onItemContextMenu : (item) =>
    menuitem.disabled = false for menuitem in @itemSpecific
    @menu.update()
    @activeItem = item

  resetMenu : =>
    menuitem.disabled = true for menuitem in @itemSpecific
    @menu.update()
    @activeItem = undefined

  # Helper method to handle messages from a view.
  # @private
  onNotifyClick : (item) =>
    @removeItem(item)
    tabs.open(item.link)
    if @displayedItems.length == 0 && preferences.hideOnEmpty
      @hideToolbar()
    else
      @send('REMOVE_ITEM', item)

  onShowDetails : (item, left) =>
    @details = Panel({
      width: 400,
      height: 200,
      position: { top: -5, left: left + 10 },
      contentURL: 'data:text/html;charset=utf-8,' + encodeURIComponent(Templater.render('details.html', item))
      contentStyleFile: './details.css'
    }).show()

  onHideDetails : =>
    if @details?
      @details.destroy()
      @details = undefined

exports.ViewManager = ViewManager
