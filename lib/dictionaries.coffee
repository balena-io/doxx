_ = require('lodash')
{ Dicts } = require('metalsmith-dynamic')

dicts = _.memoize (dir) -> Dicts.fromDir(dir)

module.exports = (config) ->
  dicts(config.dictionariesDir)
