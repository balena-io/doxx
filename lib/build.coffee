fs = require('fs')
path = require('path')
_ = require('lodash')
consolidate = require('consolidate')

Metalsmith = require('metalsmith')
markdown = require('metalsmith-markdown')
permalinks = require('metalsmith-permalinks')
layouts = require('metalsmith-layouts')
inplace = require('metalsmith-in-place')
headings = require('metalsmith-headings')
Plugins = require('./metalsmith-plugins')

Nav = require('./nav')
SwigHelper = require('./swig-helper')
HbHelper = require('./hb-helper')

module.exports = (cb) ->
  config = this.config

  navTree = null
  if config.parseNav
    navTree = Nav.parse(config)

  plugins = Plugins(config, navTree)

  SwigHelper.register(consolidate, config)
  HbHelper.register(consolidate, config)

  console.log('Building HTML...')
  metalsmith = Metalsmith(config.rootDir)
  .source(config.sourceDir)
  .destination(config.destDir)

  use = (condition, plugin, pluginArgs...) ->
    if condition
      metalsmith = metalsmith.use(plugin(pluginArgs...))

  use(true, plugins.skipPrivate)
  use(true, plugins.inferFileTitles)
  use(true, plugins.expandDynamicPages)
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

  metalsmith.build (err) ->
    return cb(err) if err
    console.log('Done')
    cb()
