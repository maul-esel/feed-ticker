{ data } = require('sdk/self')

markup = require('lib/markup')

###
Crude and basic templating engine.
###
class Templater
  ###
  Renders a template

  @param [String] template The name of the template file, relative to the data/ directory
  @param [Object] context The context to use for resolution of template variables

  @return [String] the rendered template

  @note The template format is as follows:
    {{ my_variable }} for variable replacement, including HTML escaping
    {{{ my_html }}} for replacement without HTML escaping
    {{[ my_html ]}} will be replaced with plaintext extracted from my_html
  ###
  @render : (template, context) =>
    data.load(template)
    .replace(/\{\{\{\s*(\w+)\s*\}\}\}/g, (m, property) => context[property])
    .replace(/\{\{\[\s*(\w+)\s*\]\}\}/g, (m, property) => markup.extract_text(context[property]))
    .replace(/\{\{\s*(\w+)\s*\}\}/g, (m, property) => @unhtml(context[property]))

  ###
  Helper function to escape HTML
  @private
  ###
  @unhtml : (html) =>
    markup.parse(html, 'text/html').documentElement.textContent

exports.Templater = Templater
