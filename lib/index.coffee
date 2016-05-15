_ = require('lodash')
getConfig = require('./config')
SwigHelper = require('./swig-helper')
HbHelper = require('@resin.io/doxx-handlebars-helper')
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
  layoutLocals = this.config.layoutLocals
  return _.assign {}, layoutLocals, arguments...

Doxx::loadLunrIndex = ->
  LunrSearch.loadIndex(this.config)

Doxx::lunrSearch = LunrSearch.search

Doxx.Handlebars = HbHelper.Handlebars
Doxx.swig = SwigHelper.swig

module.exports = Doxx
