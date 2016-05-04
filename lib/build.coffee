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
plugins = require('./metalsmith-plugins')

swigHelper = require('./swig-helper')
hbHelper = require('./hb-helper')

getConfig = require('./config')
dicts = require('./dictionaries')

consolidate.requires.handlebars = hbHelper.Handlebars
consolidate.requires.swig = swigHelper.swig

module.exports = (userConfig, cb) ->
  config = getConfig(userConfig)
  plugins = plugins(config)

  console.log('Building static HTML...')
  metalsmith = Metalsmith(root)
  .source(config.sourceDir)
  .destination(config.destDir)

  use = (condition, plugin, pluginArgs...) ->
    if condition
      metalsmith = metalsmith.use(plugin(pluginArgs...))

  use(true, plugins.skipPrivate)
  use(true, plugins.expandDynamicPages)
  use(true, plugins.populateFileMeta)
  use(true, plugins.fixNavTitles)
  use(true, plugins.calcNavParents)
  use(true, plugins.setBreadcrumbs)
  use(true, plugins.setNavPaths)
  use(true, plugins.buildSearchIndex)
  use(true, inplace, {
    engine: 'handlebars'
    pattern: '**/*.' + config.docsExt
    partials: config.sharedDir
  })

  use(true, markdown)
  use(true, permalinks)

  use(true, plugins.removeNavBackRefs)
  use(config.serializeNav, plugins.serializeNav)

  use(true, headings, 'h2')

  use(true, layouts, {
    engine: 'swig'
    directory: config.templatesDir
    default: config.defaultTemplate
    locals: _.assign({ nav: navTree }, config.templateLocals)
  })

  metalsmith.build (err) ->
    return cb(err) if err
    console.log('Done')
    cb()
