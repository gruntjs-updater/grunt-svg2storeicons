###
# grunt-svg2storeicons
# https://github.com/PEM--/grunt-svg2storeicons
#
# Copyright (c) 2013 Pierre-Eric Marchandet (PEM-- <pemarchandet@gmail.com>)
# Licensed under the MIT licence.
###

'use strict'

assert = require 'assert'
fs = require 'fs'
path = require 'path'

EXPECTED_DEST = path.join 'tmp', 'reduced_set'
PROFILES = (require '../lib/profiles') prjName: 'Test'

EXPECTED_FILES = []
for key in ['blackberry']
  dir = PROFILES[key].dir
  for icon in PROFILES[key].icons
    EXPECTED_FILES.push path.join EXPECTED_DEST, dir, icon.name

describe 'Reduced set', ->
  it 'should only create icons for only one profile (blackberry)', ->
    for file in EXPECTED_FILES
      assert.equal true, (fs.statSync file).isFile()
    assert.equal 1, (fs.readdirSync EXPECTED_DEST).length
    assert.equal 1,
      (fs.readdirSync path.join EXPECTED_DEST, 'res', 'icon').length
    assert.equal 'blackberry',
      (fs.readdirSync path.join EXPECTED_DEST, 'res', 'icon')[0]
