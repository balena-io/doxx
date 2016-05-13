path = require('path')
_ = require('lodash')

Dicts = require('./dictionaries')
HbHelper = require('./hb-helper')

{ replacePlaceholders, refToFilename, filenameToRef, searchOrder } = require('./util')

exports.expand = (files, config) ->
  dicts = Dicts(config)

  tokenizeSwitchText = (text) ->
    return if not text
    result = []
    start = 0
    re = /\$[\w_]+/g
    while match = re.exec(text)
      result.push(text.substring(start, match.index).trim())
      result.push(match[0])
      start = match.index + match[0].length
    remainingText = text.substring(start).trim()
    result.push(remainingText) if remainingText
    return result

  buildSinglePage = (templateObj, dynamicMeta, variablesContext) ->
    {
      ref: refFormat,
      partials_search: partialsSearchOrder,
      switch_text: switchText
    } = dynamicMeta

    originalRef = filenameToRef(templateObj.originalRef, config.docsExt)

    extendedVariablesContext = _.assign({}, variablesContext, {
      $originalRef: originalRef
    })

    refTemplate = replacePlaceholders(refFormat, {
      $originalRef: originalRef
    })

    populate = (arg) ->
      return arg if not arg

      if _.isArray(arg)
        return _.map(arg, populate)
      else if _.isObject(arg)
        return _.mapValues(arg, populate)
      else if _.isString(arg)
        return replacePlaceholders(arg, extendedVariablesContext)

    obj = _.assign({}, templateObj, {
      title: HbHelper.render(templateObj.title, templateObj)
      $partials_search: populate(partialsSearchOrder)
      $dictionaries: dicts
      $variables: variablesContext
      $ref_template: refTemplate
      $switch_text: tokenizeSwitchText(switchText)
    })

    key = refToFilename(populate(refTemplate), config.docsExt)
    return { "#{key}": obj }

  buildPagesRec = (templateObj, dynamicMeta, variablesContext, remainingVariables) ->
    if not remainingVariables?.length
      return buildSinglePage(templateObj, dynamicMeta, variablesContext)

    result = {}
    [ nextVariable, remainingVariables... ] = remainingVariables
    if nextVariable?[0] isnt '$'
      throw new Error("Variable name must start with $ sign \"#{nextVariable}\".")

    nextVariableDict = dicts.getDict(nextVariable)
    if not nextVariableDict
      throw new Error("Unknown dictionary \"#{nextVariable}\".")
    templateObj["#{nextVariable}_dictionary"] = nextVariableDict

    for details in nextVariableDict
      nextVariableId = details.id
      nextTemplateObj = _.assign({}, templateObj, {
        "#{nextVariable}_id": nextVariableId
        "#{nextVariable}": details
      })
      nextContext = _.extend({}, variablesContext, { "#{nextVariable}": nextVariableId })

      _.assign(result, buildPagesRec(
        nextTemplateObj,
        dynamicMeta,
        nextContext,
        remainingVariables
      ))

    return result

  buildDynamicPages = (file, templateObj) ->
    console.log("Expanding dynamic page #{file}")
    originalRef = filenameToRef(file, config.docsExt)
    templateObj = _.assign({ originalRef }, templateObj)
    dynamicMeta = _.assign({}, templateObj.dynamic_page)

    { variables: variablesNames } = dynamicMeta
    if not variablesNames
      throw new Error("No variables defined for the dynamic page #{file}.")

    dynamicMeta.partials_search ?= searchOrder(variablesNames)

    return buildPagesRec(templateObj, dynamicMeta, {}, variablesNames)

  for file of files
    obj = files[file]
    if not obj.dynamic_page
      continue
    delete files[file]
    _.assign(files, buildDynamicPages(file, obj))
