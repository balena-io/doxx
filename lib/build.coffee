fs = require('fs')
path = require('path')
_ = require('lodash')
consolidate = require('consolidate')

Metalsmith = require('metalsmith')
dynamic = require('metalsmith-dynamic')
markdown = require('metalsmith-markdown')
permalinks = require('metalsmith-permalinks')
layouts = require('metalsmith-layouts')
inplace = require('metalsmith-in-place')
headings = require('metalsmith-headings')
prefixoid = require('metalsmith-prefixoid')
Plugins = require('./metalsmith-plugins')

{ defaultPartialsSearch } = require('@resin.io/doxx-utils')
HbHelper = require('@resin.io/doxx-handlebars-helper')

require('handlebars-helpers')({
  handlebars: HbHelper.Handlebars
})

require('./extra-handlebars-helpers')({
  handlebars: HbHelper.Handlebars
})

Nav = require('./nav')
Dicts = require('./dictionaries')
SwigHelper = require('./swig-helper')
{ refToFilename, filenameToRef } = require('./util')

module.exports = (cb) ->
  config = this.config

  navTree = null
  if config.parseNav
    navTree = Nav.parse(config)

  plugins = Plugins(config, navTree)

  SwigHelper.register(consolidate, config)
  HbHelper.registerConsolidate(consolidate, {
    beforeRun: ->
      if not this.dynamic
        console.warn("Warning! Using import in non-dynamic page #{this.ref}.")
  })

  console.log('Building HTML...')
  metalsmith = Metalsmith(config.rootDir)
  .source(config.sourceDir)
  .destination(config.destDir)

  use = (condition, plugin, pluginArgs...) ->
    if condition
      metalsmith = metalsmith.use(plugin(pluginArgs...))

  use(true, plugins.skipPrivate)

  use(true, defaultPartialsSearch)
  use(true, dynamic, {
    dictionaries: Dicts(config)
    populateFields: [ '$partials_search' ]
    tokenizeFields: [ '$switch_text' ]
    refToFilename, filenameToRef
  })

  use(true, plugins.populateFileMeta)

  use(config.parseNav, plugins.parseNav)
  use(config.parseNav, plugins.populateFileNavMeta)
  use(config.serializeNav, plugins.serializeNav)

  use(true, inplace, {
    engine: 'handlebars'
    pattern: '**/*.' + config.docsExt
    partials: config.partialsDir
  })
  use(config.buildLunrIndex, plugins.buildSearchIndex)

  use(true, markdown)
  use(true, permalinks)

  use(true, headings, 'h2')

  use(true, layouts, {
    engine: 'swig'
    directory: config.templatesDir
    default: config.defaultTemplate
    locals: this.getLocals({ nav: navTree })
  })

  if config.pathPrefix
    use(true, prefixoid, {
      prefix: config.pathPrefix
    })

    use(true, prefixoid, {
      prefix: config.pathPrefix
      tag: 'img'
      attr: 'src'
    })

    use(true, prefixoid, {
      prefix: config.pathPrefix
      tag: 'script'
      attr: 'src'
    })

    use(true, prefixoid, {
      prefix: config.pathPrefix
      tag: 'link'
    })

  metalsmith.build (err) ->
    return cb(err) if err
    console.log('Done')
    cb()
