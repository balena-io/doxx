_ = require('lodash')
semver = require('semver')

blockHelper = (pred) -> (args..., options) ->
  if pred(args...)
    return options.fn(this)
  else
    return options.inverse(this)

helpers = {}

[
  'satisfies'
  'gt'
  'gte'
  'lt'
  'lte'
  'eq'
  'neq'
  'cmp'
].forEach (methodName) ->
  helpers["semver#{_.upperFirst(methodName)}"] = blockHelper(semver[methodName])

register = ({ handlebars }) ->
  handlebars.registerHelper(helpers)

module.exports = register
