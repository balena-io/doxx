_ = require('lodash')
config = require('./index')

module.exports = {
  rootDir: config.rootDir
  destDir: config.destDir
  buildLunrIndex: true
  parseNav: true
  serializeNav: true
  layoutLocals:
    menuLinks: config.menuLinks
}
