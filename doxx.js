#!/usr/bin/env node

var configPath = process.argv[2]

if (!configPath) {
  console.error('Config path not specified')
  process.exit(1)
}

var config = require(configPath)

var Doxx = require('./index')

Doxx(config).build(function(err) {
  if (err) {
    throw err
  }
})
