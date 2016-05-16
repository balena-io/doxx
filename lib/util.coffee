_ = require('lodash')
dynamic = require('metalsmith-dynamic')

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

exports.slugify = (s) ->
  return '' if not s
  s.toLowerCase()
    .replace(/[^a-z0-9]/gi, '-')
    .replace(/-{2,}/g, '-')
    .replace(/^-/, '')
    .replace(/-$/, '')

exports.replacePlaceholders = dynamic.util.replacePlaceholders

exports.refToFilename = (ref, ext, addExt) ->
  if ref is ''
    ref = 'index'
  return dynamic.util.refToFilename(ref, ext, addExt)

exports.filenameToRef = (filename) ->
  [ ref, ext ] = dynamic.util.filenameToRef(filename)
  if ref is 'index'
    ref = ''
  return [ ref, ext ]
