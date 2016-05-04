#!/bin/bash
dirname=$(dirname $0)
cd $dirname/..

./node_modules/.bin/coffee ./lib/build.coffee
