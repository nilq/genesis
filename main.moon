export state = require "state"

love.load = ->
  state\set "genesis"
  state\load!
  
love.update = (dt) ->
  state\update dt if state.update

love.draw = ->
  state\draw! if state.draw

love.keypressed = (key, isrepeat) ->
  state\press key, isrepeat if state.press
