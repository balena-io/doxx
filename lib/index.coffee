_ = require('lodash')
getConfig = require('./config')
SwigHelper = require('./swig-helper')
 = require('./lunr-search')

Doxx = (config) ->
  if not (this instanceof Doxx)
    return new Doxx(arguments...)

  this.config = getConfig(userConfig)

Doxx::build = require('./build')
Doxx::navParse = require('./nav').parse
Doxx.navPP = require('./nav').pp

Doxx::configureExpress = (app) ->
  SwigHelper.configureExpress(app, this.config)

Doxx::getLocals = ->
  templateLocals = this.config.templateLocals
  return _.assign {}, templateLocals, arguments...

Doxx::loadLunrIndex = ->
  LunrSearch.loadIndex(this.config)

Doxx::lunrSearch = LunrSearch.search

module.exports = Doxx
