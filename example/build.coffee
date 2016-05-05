Doxx = require('..')
doxxConfig = require('./config/doxx')

Doxx(doxxConfig)
.build (err) ->
  throw err if err
  console.log('Done')
