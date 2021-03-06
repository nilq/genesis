export state = require "state"
export util  = require "util"

require "deepcopy"

love.graphics.setBackgroundColor 255, 255, 255

love.load = ->
  state\set "genesis"
  state\load!
  
love.update = (dt) ->
  state\update dt if state.update

love.draw = ->
  state\draw! if state.draw

love.keypressed = (key, isrepeat) ->
  state\press key, isrepeat if state.press

love.mousepressed = (x, y) ->
  state\click x, y if state.click
