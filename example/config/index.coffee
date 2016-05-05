path = require('path')

module.exports = {
  rootDir: path.resolve(__dirname, '..')
  destDir: 'contents',
  menuLinks: [
    { title: 'Resin.io', link: 'https://resin.io' }
    { title: 'Resin.io Docs', link: 'https://docs.resin.io' }
    { title: 'Doxx GitHub', link: 'https://github.com/resin-io-projects/doxx' }
  ]
}
