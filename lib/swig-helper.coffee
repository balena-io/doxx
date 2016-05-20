path = require('path')
_ = require('lodash')
swig = require('swig')
consolidate = require('consolidate')
Dicts = require('./dictionaries')

{ replacePlaceholders } = require('./util')

isCurrentPage = (navNode, $nav) ->
  if navNode.isDynamic
    return $nav.url?.match(navNode.linkRe)
  return $nav.url is navNode.link

populateDynamic = (template, variablesContext, defaults) ->
  context = _.assign({}, defaults, variablesContext)
  return replacePlaceholders(template, context)

exports.register = (consolidate, config) ->
  dicts = Dicts(config)

  swig.setFilter 'navIsCurrentPage', isCurrentPage

  swig.setFilter 'navGetLink', (navNode, $nav) ->
    if isCurrentPage(navNode, $nav)
      return $nav.url
    else
      return populateDynamic(navNode.link, null, dicts.getDefaults())

  swig.setFilter 'navGetTitle', (navNode, $nav) ->
    if isCurrentPage(navNode, $nav) and navNode.isDynamic
      return $nav.title
    else
      return navNode.title

  swig.setFilter 'navIsCurrentTree', (navNode, $nav) ->
    return !!$nav.path?[navNode.$id]

  consolidate.requires.swig = swig

exports.configureExpress = (app, config) ->
  exports.register(consolidate, config)
  app.engine('html', consolidate.swig)
  app.set('view engine', 'html')
  app.set('views', path.resolve(config.rootDir, config.templatesDir))

exports.swig = swig
