var path = require('path')

module.exports = {
  rootDir: path.resolve(__dirname, '..'),
  destDir: 'contents',
  menuLinks: [
    { title: 'Balena.io', link: 'https://balena.io' },
    { title: 'Balena.io Docs', link: 'https://docs.balena.io' },
    { title: 'Doxx GitHub', link: 'https://github.com/balena-io-modules/doxx' }
  ]
}
