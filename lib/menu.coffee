{ browserWindows } = require('sdk/windows')
{ viewFor } = require('sdk/view/core')
{ identify } = require('sdk/ui/id')

{ CommonBase } = require('lib/common_base')

# Base class for everything concerning menus
# @abstract
class MenuObjectBase extends CommonBase
  # Namespace URI for XUL
  # @private
  NS_XUL = 'http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul'

  # @property [String] The base ID to be used for this object's representation in XUL documents
  @property '__xul_id__',
    get: -> "feedticker__custom-menu__#{@constructor.name}__instance#{@__instance_number__}"

  # Creates a XUL element
  #
  # @param [Document] doc The document where the element should be created
  # @param [String] tag The tag name (no namespace prefix)
  # @param [Object] attributes An object with attributes for the element
  # @param [Element[]] children Child elements to add to the created element
  # @param [Object] listeners An object with event names and listeners for those events
  #
  # @return [Element] the newly created DOM element
  createElement : (doc, tag, attributes = {}, children = [], listeners = {}) =>
    element = doc.createElementNS(NS_XUL, tag)
    element.setAttribute(key, value) for key, value of attributes
    element.appendChild(child) for child in children
    element.addEventListener(event, listener) if listener? for event, listener of listeners
    element

  # Builds the DOM for the menu object
  # @abstract
  #
  # @param [Document] doc The DOM document where the object should be built
  #
  # @return [Element] The DOM element representing the menu object
  build : (doc, id_suffix) =>

  # Updates an attribute on DOM elements representing this object in browser windows
  #
  # @param [String] attribute The attribute to update
  # @param [String,Boolean,Number] The value the attribute is set to
  updateAttribute : (attribute, value) =>
    for window in browserWindows
      doc = viewFor(window).document
      for suffix in @menu.getIdSuffixes()
        doc.getElementById(@__xul_id__ + suffix)?.setAttribute(attribute, value)

# Base class for menus
# @abstract
class MenuBase extends MenuObjectBase
  # The items contained in the menu
  items : []

  # @event hide
  @event 'hide'

  # Creates a new instance of the class
  #
  # @param [Object] options Options for the instance
  # @param [Array<MenuObjectBase>] items The items of this menu
  constructor: (@options = {}, items = []) ->
    @items = []
    @append(item) for item in items

  # Appends an item to the menu
  #
  # @param [MenuItem,SubMenu,MenuSeparator] item The item to append
  append : (item) =>
    item.menu = this
    @items.push(item)

  # Inserts an item into the menu
  #
  # @param [Integer] index The index where the item should be inserted
  # @param [MenuItem,SubMenu,MenuSeparator] item The item to insert
  insert : (index, item) =>
    item.menu = this
    @items[index...index] = [item]

  build : (doc, id_suffix) =>
    @createElement(doc,
      'menupopup',
      { id: @__xul_id__ + id_suffix },
      item.build(doc, id_suffix) for item in @items,
      { popuphiding: @onHide }
    )

  getIdSuffixes : =>
    @menu.getIdSuffixes()

# Represents a simple item in a menu
class MenuItem extends MenuObjectBase
  # Creates a new menu item
  #
  # @param [Object] options Options for the item
  #
  # @option options [String] label The display label for the item
  # @option options [Boolean] disabled True to disable the item
  # @option options [Boolean] checked True to display a check mark next to the item
  # @option options [String] image The URI of an icon to display next to the item
  # @option options [Function] onCommand A callback to be called when the item is selected
  constructor : (@options = {}) ->

  @option 'label'
  @option 'disabled', false
  @option 'checked', false
  @option 'image', ''

  @event 'command'

  build : (doc, id_suffix) =>
    @createElement(doc, 'menuitem', {
      id: @__xul_id__ + id_suffix,
      label: @label,
      disabled: @disabled,
      checked: @checked,
      image: @image
    }, [], { command: @onCommand })

  onOptionChanged : (option, oldValue, newValue) =>
    switch option
      when 'disabled' then @updateAttribute(option, newValue)

# Represents a menu item containing a sub menu
class SubMenu extends MenuBase
  # Creates a new sub menu
  #
  # @param [Object] options
  # @param [Array] items The items the sub menu will contain
  constructor : (options = {}, items = []) ->
    super(options, items)

  @option 'label'
  @option 'disabled', false
  @option 'image', ''

  build : (doc, id_suffix) =>
    @createElement(doc, 'menu', { id: @__xul_id__ + id_suffix, label: @label }, [ super(doc) ])

# Represents an item separator element
class MenuSeparator extends MenuObjectBase
  build : (doc, id_suffix) =>
    @createElement(doc, 'menuseparator', { id: @__xul_id__ + id_suffix })

# Represents a menu for firefox UI elements
class Menu extends MenuBase
  # A menu item representing a separator
  @Separator : new MenuSeparator

  contextMenuTargets: []
  menuButtonTargets: []

  # Creates a new context menu
  #
  # @param [Array] items The items the menu will contain
  constructor : (options = {}, items = []) ->
    super(options, items)
    @menu = @
    browserWindows.on('open', @onNewWindow)
    [@contextMenuTargets, @menuButtonTargets] = [[], []] # needed, otherwise instances share them

  # Sets this menu as context menu on a given target
  #
  # @param [String,Object] target The target for the context menu, either as XUL ID (String)
  #   or as an object on which @see identify() returns the XUL id.
  contextMenu : (target) =>
    target = identify(target) unless typeof(target) == 'string'
    @contextMenuTargets.push(target)
    @setContextMenu(viewFor(window).document, target) for window in browserWindows

  # Sets this menu as button menu on a given button
  #
  # @param [String,Object] target The button to use, or its XUL ID
  # @param [Boolean] menuOnly True to create a menu-only button, false for a button
  #   that has a separate command action
  menuButton : (target, menuOnly = true) =>
    target = identify(target) unless typeof(target) == 'string'
    @menuButtonTargets.push([target, menuOnly])
    @setButtonMenu(viewFor(window).document, target, menuOnly) for window in browserWindows

  # @private
  onNewWindow : (window) =>
    doc = viewFor(window).document
    @setContextMenu(doc, target) for target in @contextMenuTargets
    @setButtonMenu(doc, target, menuOnly) for [target, menuOnly] in @menuButtonTargets

  # @private
  setContextMenu : (doc, target) =>
    unless doc.getElementById(@__xul_id__ + '__context')?
      doc.getElementById('mainPopupSet').appendChild(@build(doc, '__context'))
    doc.getElementById(target)?.setAttribute('context', @__xul_id__ + '__context')

  # @private
  setButtonMenu : (doc, target, menuOnly) =>
    button = doc.getElementById(target)
    button.setAttribute('type', if menuOnly then 'menu' else 'menu-button')
    button.classList.remove('badged-button')
    button.appendChild(@build(doc, '__button__' + target))

  # @private
  getIdSuffixes : =>
    suffixes = ('__button__' + target for [target, menuOnly] in @menuButtonTargets)
    suffixes.push('__context') if @contextMenuTargets.length > 0
    suffixes

exports.Menu = Menu
exports.MenuItem = MenuItem
exports.SubMenu = SubMenu
