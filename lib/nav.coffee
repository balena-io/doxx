fs = require('fs')
_ = require('lodash')
{ walkTree } = require('./util')

fixLinks = walkTree
  visitNode: (node) ->
    if node.level? and not node.link
      if not node.children?.length
        throw new Error("No link and no child lines. #{node.raw}")
      node.isGateway = true
      node.link = node.children[0].link

calcRefs = walkTree
  visitNode: (node) ->
    { link } = node
    if link and link[0] is '/'
      node.ref = link[1..]

    if node.level? and not node.ref? and not node.title
      throw new Error("No title for external link node. #{node.raw}")

calcIds = (rootNode, rootId) ->
  setId = (node, id) ->
    node.$id = id
    if node.children
      for child, i in node.children
        setId(child, "#{id}.#{i + 1}")
  setId(rootNode, rootId)

exports.parse = (config) ->
  lines = fs.readFileSync(config.parseNav)
  .toString()
  .split('\n')
  .map (s) -> s.trimRight()
  .filter (s) -> s and not s.match(/\s*#/)
  .map (s) ->
    [ pad, line ] = s.match(/^(\s*)(.*)$/)[1..]
    if pad.length % 2 or not pad.match(/^ *$/)
      throw new Error("Wrong indent! Must be even and spaces-only. #{s}")
    return { level: pad.length / 2, raw: line }
  .map ({ level, raw }) ->
    [ title, skip, link ] = raw.match(/^([^\[]+)?(\[(.+)\])?$/)[1..]
    node = { level, raw, title, link }
    if link?.match(/\$/)
      node.isDynamic = true
      linkReParts = link.split(/\$[\w_]+/).map(_.escapeRegExp)
      node.linkRe = new RegExp('^' + linkReParts.join('.*') + '$')
      if not title
        throw new Error("Dynamic pages must specify the title. #{raw}")
      titleParts = title.split(/\s*~\s*/)
      node.title = titleParts[0]
      node.titleTemplate = titleParts[1] or titleParts[0]
    return node

  trees = []
  currentNode = null

  for line in lines
    if not currentNode?
      if line.level isnt 0
        throw new Error("First line must have no indent. #{line.raw}")

      trees.push(line)
    else
      if line.level > currentNode.level + 1
        throw new Error("Indent too big. #{line.raw}")

      while currentNode and line.level <= currentNode.level
        currentNode = currentNode.parent
      if not currentNode
        trees.push(line)
      else
        currentNode.children ?= []
        currentNode.children.push(line)
        line.parent = currentNode

    currentNode = line

  result =
    level: null
    ref: undefined
    link: null
    title: '<root>'
    raw: '<root>'
    children: trees

  fixLinks(result)
  calcRefs(result)
  calcIds(result, '$0')

  return result

ppNode = walkTree
  visitNode: (node, indent = '') ->
    title = node.title or '(No title)'
    link = if node.link then "[#{node.link}]" else ''
    console.log "#{indent}|--#{title}#{link}"
  buildNextArgs: (node, indent = '') ->
    [ indent + '|  ' ]

exports.pp = (tree) ->
  ppNode(tree)

exports.serialize = (tree, path) ->
  return
