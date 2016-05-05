path = require('path')
express = require('express')
_ = require('lodash')

navTree = require('./nav.json')
config = require('./config')

Doxx = require('..')
doxxConfig = require('./config/doxx')

app = express()
doxx = Doxx(doxxConfig)
doxx.configureExpress(app)

staticDir = path.join(__dirname, 'static')
contentsDir = path.join(__dirname, config.destDir)

app.use(express.static(staticDir))

getLocals = (extra) ->
  doxx.getLocals({ nav: navTree }, extra)

doxx.loadLunrIndex()

app.get '/search-results', (req, res) ->
  { searchTerm } = req.query
  res.render 'search', getLocals
    title: "Search results for \"#{searchTerm}\""
    breadcrumbs: [
      'Search Results'
      searchTerm
    ]
    searchTerm: searchTerm
    searchResults: doxx.lunrSearch(searchTerm)

app.use(express.static(contentsDir))

app.get '*', (req, res) ->
  res.render 'not-found', getLocals
    title: "We don't seem to have such page"
    breadcrumbs: [ 'Page not found' ]

port = process.env.PORT ? 3000

app.listen port, ->
  console.log("Server started on port #{port}")
