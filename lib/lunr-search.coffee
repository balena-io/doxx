lunr = require('lunr')

index = null

exports.loadIndex = (config) ->
  indexDump = require(config.buildLunrIndex)

  index = {
    lunr: lunr.Index.load(indexDump.idx),
    docs: indexDump.docsIdx
  }

exports.search = (searchTerm) ->
  if not index?
    throw new Error('Doxx: Lunr index must be loaded before using search.')

  return index.lunr.search(searchTerm)
  .map (result) ->
    { ref } = result
    return {
      id: ref,
      title: index.docs[ref],
      link: '/' + ref
    }
