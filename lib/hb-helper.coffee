_ = require('lodash')
Handlebars = require('handlebars')
{ stringifyPairs } = require('./util')

exports.compileTemplate = compileTemplate = _.memoize (tpl) ->
  return Handlebars.compile(tpl)

exports.render = (template, context) ->
  compiled = compileTemplate(template)
  return compiled(context)

exports.getPartial = getPartial = _.memoize (key) ->
  partial = Handlebars.partials[key]
  return if not partial
  return compileTemplate(partial)

exports.getBestPartial = getBestPartial = (prefix, options, sep = '/') ->
  for option in options
    partial = getPartial("#{prefix}#{sep}#{option}")
    return partial if partial

exports.importHelper = importHelper = (prefix) ->
  if not this.dynamic_page
    throw new Error("Using import in non-dynamic page #{this.ref}.")
  partial = getBestPartial(prefix, this.$partials_search)
  if partial
    return new Handlebars.SafeString(partial(this))
  throw new Error("""Can't find any matching import for "#{prefix}".
    Context: #{stringifyPairs(this.$axes_values)}.
    Partials search: #{this.$partials_search?.join(', ')}.
  """)

exports.register = (consolidate) ->
  Handlebars.registerHelper 'import', importHelper

  consolidate.requires.handlebars = Handlebars
