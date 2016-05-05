path = require('path')
fs = require('fs')

_ = require('lodash')
LunrIndex = require('./lunr-index')
DynamicPages = require('./dynamic-pages')
Dicts = require('./dictionaries')
HbHelper = require('./hb-helper')

{ extractTitleFromText, walkTree, slugify, replacePlaceholders,
  filenameToRef, refToFilename, getValue } = require('./util')

walkFiles = (fn) ->
  return (options) ->
    return (files, metalsmith, done) ->
      for file of files
        fn(file, files, metalsmith, options)
      done()

module.exports = (config, navTree) ->
  dicts = Dicts(config)
  exports = {}

  exports.skipPrivate = walkFiles (file, files) ->
    if path.parse(file).name.match(/^_/)
      delete files[file]

  exports.inferFileTitles = walkFiles (file, files) ->
    obj = files[file]
    obj.title or= extractTitleFromText(obj.contents.toString())

  exports.populateFileMeta = walkFiles (file, files) ->
    obj = files[file]
    obj.ref = filenameToRef(file, config.docsExt)
    obj.selfLink = '/' + obj.ref
    _.assign(obj, getValue(config.metaExtra, file, obj))

  exports.buildSearchIndex = ->
    console.log('Building search index...')
    searchIndex = LunrIndex.create()

    return (files, metalsmith, done) ->
      for file of files
        obj = files[file]
        searchIndex.add
          id: obj.ref
          title: obj.title
          body: obj.contents.toString()
      indexFilePath = config.buildLunrIndex
      searchIndex.write indexFilePath, (err) ->
        throw err if err
        console.log('Successfully finished indexing.')
        done()

  navByFile = null

  exports.parseNav = ->
    setRefRec = (ref, node, remainingAxes) ->
      if not remainingAxes?.length
        return setRef(ref, node)
      nextAxis = remainingAxes[0]
      remainingAxes = remainingAxes[1...]
      for value in dicts.getValues(nextAxis)
        setRefRec(
          replacePlaceholders(ref, { "#{nextAxis}": value }),
          node,
          remainingAxes
        )

    setRef = (ref, node) ->
      return if not ref?
      if ref.indexOf('$') >= 0
        setRefRec(ref, node, dicts.dictNames)
      else
        navByFile[refToFilename(ref, config.docsExt)] = node

    setRefs = walkTree
      visitNode: (node) ->
        if node.level?
          setRef(node.ref, node)

    fixNavNodeTitleAndSetSlug = walkTree
      visitNode: (node, files) ->
        if node.level?
          node.title or= files[refToFilename(node.ref, config.docsExt)]?.title
          node.slug = slugify(node.title)

    addNavParents = walkTree
      visitNode: (node, parents) ->
        if node.level?
          node.parents = parents.concat(node)
      buildNextArgs: (node, parents) ->
        if node.level?
          [ parents.concat(node) ]
        else
          [ parents ]

    return (files, metalsmith, done) ->
      console.log('Parsing navigation...')

      fixNavNodeTitleAndSetSlug(navTree, files)
      addNavParents(navTree, [])

      navByFile = {}
      setRefs(navTree)

      console.log('Navigation parsed and indexed.')
      done()

  exports.serializeNav = ->
    # needed because of
    # https://github.com/superwolff/metalsmith-layouts/issues/83
    removeBackRefs = walkTree
      visitNode: (node) ->
        delete node.parent
        delete node.parents

    return (files, metalsmith, done) ->
      removeBackRefs(navTree)

      filename = config.serializeNav
      fs.writeFile filename, JSON.stringify(navTree), (err) ->
        throw err if err
        console.log('Successfully serialized navigation tree.')
      done()

  exports.populateFileNavMeta = ->

    setBreadcrumbsForFile = (file, obj) ->
      navNode = navByFile[file]
      obj.breadcrumbs = bc = navNode?.parents
        .map (node) -> node.title
      # TODO: this logic is twisted and should be improved
      if navNode?.isDynamic and bc?.length
        bc[bc.length - 1] =
          HbHelper.render(navNode.titleTemplate, obj)

    setPathForFile = (file, obj) ->
      if navPath = navByFile[file]?.parents
        obj.navPath = {}
        for node in navPath
          obj.navPath[node.$id] = true

    return (files, metalsmith, done) ->
      for file of files
        obj = files[file]
        setPathForFile(file, obj)
        setBreadcrumbsForFile(file, obj)
      done()

  exports.expandDynamicPages = ->
    return (files, metalsmith, done) ->
      DynamicPages.expand(files, config)
      done()


  return exports
