_ = require('lodash')
getConfig = require('./config')
SwigHelper = require('./swig-helper')
LunrSearch = require('./lunr-search')
Nav = require('./nav')

Doxx = (config) ->
  if not (this instanceof Doxx)
    return new Doxx(arguments...)

  this.config = getConfig(config)
  return

Doxx::build = require('./build')

Doxx::navParse = ->
  Nav.parse(this.config)
Doxx.navPP = Nav.pp

Doxx::configureExpress = (app) ->
  SwigHelper.configureExpress(app, this.config)

Doxx::getLocals = ->
  templateLocals = this.config.templateLocals
  return _.assign {}, templateLocals, arguments...

Doxx::loadLunrIndex = ->
  LunrSearch.loadIndex(this.config)

Doxx::lunrSearch = LunrSearch.search

module.exports = Doxx
