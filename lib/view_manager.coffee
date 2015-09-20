{ ActionButton } = require('sdk/ui/button/action')
{ Frame } = require('sdk/ui/frame')
{ Toolbar } = require('sdk/ui/toolbar')
{ Panel } = require('sdk/panel')

{ EventTarget } = require('sdk/event/target')
{ emit } = require('sdk/event/core')

simplePrefs = require('sdk/simple-prefs')
{ identify } = require('sdk/ui/id')
_ = require('sdk/l10n').get

{ Templater } = require('lib/templater')
{ Menu, MenuItem, SubMenu } = require('lib/menu')

###
Manages the displayed items.
Communicates with {View} instances running in the context of the UI's frame.
###
class ViewManager extends EventTarget
  ###
  The list of items displayed in the toolbar.
  @private
  ###
  displayedItems : []

  constructor : ->
    @createUI()
    simplePrefs.on('hideOnEmpty', =>
      if @displayedItems.length == 0
        if simplePrefs.prefs.hideOnEmpty
          @hideToolbar()
        else
          @showToolbar()
    )

  ###
  Clears the list of displayed items
  @note To have any effect on the UI, {#update} must be called after any calls ot this method.
  ###
  clear : =>
    @displayedItems = []

  ###
  Adds a new item to be displayed or updates an existing one.

  @param item [FeedItem] The item to be displayed

  @note To have any effect on the UI, {#update} must be called after any calls ot this method.
  ###
  displayItem : (item) =>
    index = @displayedItems.findIndex((other) => other.id == item.id)
    if (index == -1)
      @displayedItems.push(item) # TODO: insert at specific position
    else
      @displayedItems[index] = item

  ###
  Removes an item from the list of displayed items, if it exists there.

  @param item [FeedItem] The item to be removed

  @note Unlike {#displayItem}, this method triggers an immediate update.
  ###
  removeItem : (item) =>
    index = @displayedItems.findIndex((other) => other.id == item.id)
    @displayedItems[index..index] = [] unless index == -1

    if @displayedItems.length == 0 && simplePrefs.prefs.hideOnEmpty
      @hideToolbar()
    else
      @send('REMOVE_ITEM', item)

  ###
  Updates views with the changes made to the list of displayed items.

  @param view The view to update
  @param origin The origin fro the view update

  @note The parameters are for internal use by this class only.
  ###
  update : (view = null, origin = null) =>
    if @displayedItems.length == 0 && simplePrefs.prefs.hideOnEmpty
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
      title: _('toolbar_title'),
      items: [@frame],
      onAttach: => @menu.contextMenu('inner-' + identify(@toolbar))
    }) unless @toolbar?

  ###
  Helper method to create the toolbar UI
  @private
  ###
  createUI : =>
    @frame = Frame(
      url: './ticker.html'
      onMessage: @onReceiveMessage
    )
    @itemSpecific = []
    @menu = new Menu(onHide: @resetMenu, [
      new MenuItem(label: _('refresh_feeds'), onCommand: => emit(this, 'refresh'))
      Menu.Separator
      @itemSpecific[...0] = new MenuItem(
        label: _('open_feed_in_tabs')
        disabled: true
        onCommand: => emit(this, 'open', @activeItem.feed)
      )
      new MenuItem(label: _('open_all_in_tabs'), onCommand: => emit(this, 'open', null))
      Menu.Separator
      @itemSpecific[...0] = new MenuItem(
        label: _('mark_item_read')
        disabled: true
        onCommand: => emit(this, 'mark_read', @activeItem)
      )
      @itemSpecific[...0] = new MenuItem(
        label: _('mark_feed_read')
        disabled: true
        onCommand: => emit(this, 'mark_read', @activeItem.feed)
      )
      new MenuItem(label: _('mark_all_read'), onCommand: => emit(this, 'mark_read', null))
    ])

    btn = ActionButton(
      id: 'ticker-toolbar-menu-button'
      label: 'FeedTicker'
      icon: './icon.png'
    )
    new Menu({}, [
      new MenuItem(label: _('refresh_feeds'), onCommand: => emit(this, 'refresh'))
      new MenuItem(label: _('open_all_in_tabs'), onCommand: => emit(this, 'open', null))
      new MenuItem(label: _('mark_all_read'), onCommand: => emit(this, 'mark_read', null))
    ]).menuButton(btn, true)

  ###
  Helper method for communication with the {View} instances
  @private

  @param command [String] The command to send to the views
  @param data [String,Number,Object] Additional data to send
  @param view The view to update. If omitted, all views are updated.
  @param origin The origin for the update. Used in conjunction with the previous parameter
  ###
  send : (command, data, view = null, origin = null) =>
    (view ? @frame).postMessage(JSON.stringify({
      command: command,
      data: data
    }), origin ? @frame.url)

  ###
  Callback method for communication with the {View} instances
  @private
  ###
  onReceiveMessage : (event) =>
    message = JSON.parse(event.data)
    switch message.command
      when 'READY'
        @onViewReady(event.source, event.origin)
      when 'NOTIFY_CLICK'
        emit(this, 'open', message.data)
      when 'SHOW_DETAILS'
        @onShowDetails(message.data.item, message.data.left)
      when 'HIDE_DETAILS'
        @onHideDetails()
      when 'CONTEXT_MENU'
        @onItemContextMenu(message.data)

  ###
  Helper method to handle messages from a view.
  @private
  ###
  onViewReady : (view, origin) =>
    @update(view, origin)

  onItemContextMenu : (item) =>
    menuitem.disabled = false for menuitem in @itemSpecific
    @activeItem = item

  resetMenu : =>
    if @activeItem?
      menuitem.disabled = true for menuitem in @itemSpecific
      @activeItem = undefined

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
