swig = require('swig')
_ = require('lodash')
Dicts = require('./dictionaries')
consolidate = require('consolidate')

{ replacePlaceholders } = require('./util')

isCurrentPage = (navNode, selfLink) ->
  if navNode.isDynamic
    return selfLink.match(navNode.linkRe)
  return selfLink is navNode.link

populateDynamic = (template, axesValues, defaults) ->
  context = _.assign({}, defaults, axesValues)
  return replacePlaceholders(template, context)

exports.register = (consolidate, config) ->
  dicts = Dicts(config)

  swig.setFilter 'isCurrentPage', isCurrentPage

  swig.setFilter 'getLink', (navNode, selfLink) ->
    if isCurrentPage(navNode, selfLink)
      return selfLink
    else
      return populateDynamic(navNode.link, null, dicts.getDefaults())

  swig.setFilter 'getTitle', (navNode, selfLink, title) ->
    if isCurrentPage(navNode, selfLink) and navNode.isDynamic
      return title
    else
      return navNode.title

  swig.setFilter 'isCurrentTree', (navNode, navPath) ->
    return navPath[navNode.link]

  consolidate.requires.swig = swig

exports.configureExpress = (app, config) ->
  exports.register(consolidate, config)
  app.engine('html', consolidate.swig)
  app.set('view engine', 'html')
  app.set('views', config.templatesDir)
