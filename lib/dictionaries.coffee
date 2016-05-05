fs = require('fs')
path = require('path')
_ = require('lodash')

KNOWN_EXTS = [
  'js'
  'coffee'
  'json'
]

Dicts = (config) ->
  dir = config.dictionariesDir

  if dir
    extsRe = new RegExp("\\.(#{KNOWN_EXTS.join('|')})$")
    files = fs.readdirSync(path.resolve(__dirname, dir))
      .filter (file) -> file.match(extsRe)
      .map (file) ->
        ext = path.extname(file)
        return path.basename(file, ext)
  else
    files = []

  dicts = {}

  for file in files
    dicts["$#{file}"] = require("#{dir}/#{file}")

  keys = files.map (file) -> "$#{file}"

  dicts.dictNames = keys

  dicts.getDict = (key) -> dicts[key]

  dicts.getValues = (key) ->
    _.map dicts[key], 'id'

  dicts.getDetails = (key, id) ->
    _.find dicts.getDict(key), { id }

  dicts.getDefault = (key) ->
    _.first(dicts.getDict(key))?.id

  dicts.getDefaults = ->
    result = {}
    for key in keys
      result[key] = dicts.getDefault(key)
    return result

  return dicts

module.exports = Dicts
