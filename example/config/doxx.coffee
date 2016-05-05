_ = require('lodash')

module.exports = _.assign {}, require('./index'), {
  buildLunrIndex: true
  parseNav: true
  serializeNav: true
}
