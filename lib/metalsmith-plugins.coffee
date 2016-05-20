path = require('path')
fs = require('fs')
_ = require('lodash')

HbHelper = require('@resin.io/doxx-handlebars-helper')
{ walkFiles, walkTree } = require('@resin.io/doxx-utils')

LunrIndex = require('./lunr-index')
Dicts = require('./dictionaries')

{ extractTitleFromText, slugify, replacePlaceholders,
  filenameToRef, refToFilename, getValue } = require('./util')


module.exports = (config, navTree) ->
  dicts = Dicts(config)
  exports = {}

  exports.skipPrivate = walkFiles (file, files) ->
    if path.parse(file).name.match(/^_/)
      delete files[file]

  fileByRef = {}

  exports.populateFileMeta = walkFiles (file, files) ->
    obj = files[file]
    title = obj.title or extractTitleFromText(obj.contents.toString())
    obj.title = HbHelper.render(title, obj)
    [ obj.ref, obj.ext ] = filenameToRef(file)
    fileByRef[obj.ref] = obj
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

  navByRef = null

  exports.parseNav = ->
    setRefRec = (ref, node, remainingVariables) ->
      if not remainingVariables?.length
        return setRef(ref, node)
      [ nextVariable, remainingVariables... ] = remainingVariables
      for value in dicts.getValues(nextVariable)
        setRefRec(
          replacePlaceholders(ref, { "#{nextVariable}": value }),
          node,
          remainingVariables
        )

    setRef = (ref, node) ->
      return if not ref?
      if ref.indexOf('$') >= 0
        setRefRec(ref, node, dicts.dictNames)
      else
        navByRef[ref] = node

    setRefs = walkTree
      visitNode: (node) ->
        if node.level?
          setRef(node.ref, node)

    fixNavNodeTitleAndSetSlug = walkTree
      visitNode: (node) ->
        if node.level?
          node.title or= fileByRef[node.ref]?.title
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

      fixNavNodeTitleAndSetSlug(navTree)
      addNavParents(navTree, [])

      navByRef = {}
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

  exports.populateFileNavMeta = walkFiles (file, files) ->
    obj = files[file]
    { ref } = obj
    navNode = navByRef[ref]

    obj.$nav = $nav =
      url: "/#{obj.ref}"

    # set nav path
    if parents = navNode?.parents
      $nav.path = {}
      for node in parents
        $nav.path[node.$id] = true

    # set breadcrumbs
    obj.breadcrumbs = bc = navNode?.parents?.map (node) -> node.title
    # TODO: this logic is twisted and should be improved
    if navNode?.isDynamic
      $nav.title = HbHelper.render(navNode.titleTemplate, obj)
      if bc?.length
        bc[bc.length - 1] = $nav.title
    else
      $nav.title = navNode.title

  return exports
