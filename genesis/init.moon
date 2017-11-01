scene = {}

agent = require "genesis/agent"

scene.load = =>
  math.randomseed os.time!
  @agents = {}
  
scene.spawn = =>
  @agents[#@agents + 1] = agent.agent!

scene.update = (dt) =>
  if love.mouse.isDown 1    
    x = love.mouse.getX!
    y = love.mouse.getY!

    for a in *@agents
      if (util.distance {x, y}, {a.hull.pos.x, a.hull.pos.y}) < a.hull.radius
        @focused = a
        break
      else
        @focused = nil
  
  for agent in *@agents
    agent\update dt if agent.update

scene.draw = =>
  for agent in *@agents
    agent\draw! if agent.draw
      
  @focused.brain\draw @focused.hull.pos.x, @focused.hull.pos.y if @focused

scene.press = (key) =>
  if key == "space"
    for _ = 1, 1
      @spawn!

scene
