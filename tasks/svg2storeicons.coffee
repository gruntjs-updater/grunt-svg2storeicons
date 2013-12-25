###
# grunt-svg2storeicons
# https://github.com/PEM--/grunt-svg2storeicons
#
# Copyright (c) 2013 Pierre-Eric Marchandet (PEM-- <pemarchandet@gmail.com>)
# Licensed under the MIT licence.
###

'use strict'

# GraphicsMagick (node-gm) is used for every conversion and resizing tasks
gm = require 'gm'
# Async is used to transfomr this task as an asynchronous task
async = require 'async'

###
# All profiles for every app stores covered by PhoneGap are stored hereafter
# The name of the icon is used as the final name under rendered icon.
# The size represents a squared icon and is provided as-is to avoid name
#  as the naming conventions from PhoneGap may vary and produce weird
#  resolution schemes.
###
PROFILES = {
  # iOS (Retina and legacy resolutions)
  'ios': [
    { name: 'icon57.png', size: 57 }
    { name: 'icon57-2x.png', size: 114 }
    { name: 'icon72.png', size: 72 }
    { name: 'icon-72-2x.png', size: 144 }
  ]
  # Android
  'android': [
    { name: 'icon-36-ldpi.png', size: 36 }
    { name: 'icon-48-mdpi.png', size: 48 }
    { name: 'icon-72-hdpi.png', size: 72 }
    { name: 'icon-96-xhdpi.png', size: 96 }
  ]
  # Windows Phone, Tablets and Desktop (Windows 8)
  'windows-phone': [
    { name: 'icon-48.png', size: 48 }
    { name: 'icon-62-tile.png', size: 62 }
    { name: 'icon-173-tile.png', size: 173 }
  ]
  # Blackberry
  'blackberry': [
    { name: 'icon-80.png', size: 80 }
  ]
  # WebOS
  'webos': [
    { name: 'icon-64.png', size: 64 }
  ]
  # All Bada's icon's sets
  'bada': [
    { name: 'icon-128.png', size: 128 }
    { name: 'icon-48-type5.png', size: 48 }
    { name: 'icon-50-type3.png', size: 50 }
    { name: 'icon-80-type4.png', size: 80 }
  ]
  # Tizen
  'tizen': [
    { name: 'icon-128.png', size: 128 }
  ]
}

module.exports = (grunt) ->
  grunt.registerMultiTask 'svg2storeicons', \
      'Create all stores icons from a single SVG file', ->
    # Call this function when inner tasks are achieved.
    done = @async()
    # Default options are set to produce all stores icons.
    # This setting can be surcharged by user.
    options = @options profiles: [
      'ios', 'android', 'windows-phone'
      'blackberry', 'webos', 'bada', 'tizen'
    ] # Check existence of source file
    return done new Error "Only one source file is allowed: #{@files}" \
      if @files.length isnt 1 or @files[0].orig.src.length isnt 1
    SRC = @files[0].orig.src[0]
    return done new Error "Source file '#{SRC}' not found: #{@files}" \
      if not grunt.file.exists SRC
    # Create the result's folder
    DEST = @files[0].dest
    grunt.file.mkdir DEST
    # Iterate over each selected profile
    async.each options.profiles, (profile, nextProfile) ->
      grunt.log.ok "Profile: #{profile}"
      # Create a directories for each profile
      grunt.file.mkdir "#{DEST}/#{profile}"
      async.each PROFILES[profile], (destIcon, nextIcon) ->
        # Create the icon in the appropriate directory.
        # The background icon is transparent.
        # The density of the SVG is multiply by 4 so that it gets
        #  antialiased when resized and written to disk.
        grunt.log.ok "#{SRC} -> #{DEST}/#{profile}/#{destIcon.name}"
        gm(SRC).
          background('none').
          density(destIcon.size*4, destIcon.size*4).
          resize(destIcon.size, destIcon.size, '!').
          write "#{DEST}/#{profile}/#{destIcon.name}", (err) ->
            return nextIcon err if err
            nextIcon()
      , nextProfile
    , (err) ->
      if err
        grunt.log.error err.message
        done false
      done()