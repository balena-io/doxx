_ = require('lodash')
Combinatorics = require('js-combinatorics')

exports.getValue = (value, restArgs...) ->
  if typeof value is 'function'
    value = value(restArgs...)
  return value

exports.extractTitleFromText = (body) ->
  headings = body
    .split('\n')
    .map (s) -> s.trim()
    .filter (s) -> s[0] is '#'
  return headings[0]?.replace(/\#+\s?/, '')

exports.walkTree = ({ visitNode, buildNextArgs }) ->
  self = (node, restArgs...) ->
    visitNode(node, restArgs...)
    if node.children?
      nextArgs = if buildNextArgs? then buildNextArgs(node, restArgs...) else restArgs
      for child in node.children
        self(child, nextArgs...)

  return self

exports.slugify = (s) ->
  return '' if not s
  s.toLowerCase()
    .replace(/[^a-z0-9]/gi, '-')
    .replace(/-{2,}/g, '-')
    .replace(/^-/, '')
    .replace(/-$/, '')

exports.stringifyPairs = (obj) ->
  s = []
  for key, value of obj
    s.push("#{key}: #{value}")
  return s.join(', ')

exports.replacePlaceholders = (arg, context) ->
  for key, value of context
    re = new RegExp(_.escapeRegExp(key), 'g')
    arg = arg.replace(re, value)
  return arg

exports.refToFilename = (ref, ext) ->
  if ref is ''
    ref = 'index'
  return "#{ref}.#{ext}"

exports.filenameToRef = (filename, ext) ->
  extRe = new RegExp("\\.#{ext}$")
  ref = filename.replace(extRe, '')
  if ref is 'index'
    ref = ''
  return ref

compareCombinations = (a, b) ->
  la = a.length
  lb = b.length
  # longer has higher specificity
  if la != lb
    return lb - la
  # later items have lower priority
  # so the combination that skips higher index items has higher specificity
  for i in [0...la]
    if a[i] != b[i]
      return a[i] - b[i]
  return 0

exports.searchOrder = (variables) ->
  count = variables?.length
  if not count
    result = []
  else
    idx = [0...count]
    combinations = Combinatorics.power(idx)
    .toArray()
    .filter (a) -> !!a.length
    .sort(compareCombinations)

    result = combinations.map (c) ->
      c.map (i) -> variables[i]
      .join('+')

  return result.concat('_default')
