{ data } = require('sdk/self')

markup = require('lib/markup')

###
Crude and basic templating engine.
###
class Templater
  ###
  Renders a template

  @param template [String] The name of the template file, relative to the data/ directory
  @param context [Object] The context to use for resolution of template variables

  @return [String] the rendered template

  @note The template format is as follows:
    {{ my_variable }} for variable replacement
    {{[ my_html ]}} will be replaced with plaintext extracted from my_html
  ###
  @render : (template, context) =>
    data.load(template)
    .replace(/\{\{\[\s*(\w+)\s*\]\}\}/g, (m, property) => markup.extract_text(context[property]))
    .replace(/\{\{\s*(\w+)\s*\}\}/g, (m, property) => context[property])

exports.Templater = Templater
