scene = {}

agent = require "genesis/agent"

scene.load = =>
  math.randomseed os.time!
  @agents = {}
  @food   = {}
  @count  = 0
  
  for x = 0, love.graphics.getWidth! / 32
    a = {}
    for y = 0, love.graphics.getWidth! / 32
      if 0 == math.random 0, 3
        a[y] = math.random 0, 0.5
      else
        a[y] = 0

    @food[x] = a
  
scene.spawn = =>
  @agents[#@agents + 1] = agent.agent!

scene.update = (dt) =>
  @count += 1
  
  if @count % 120 == 0
    x = util.randi 0, #@food
    y = util.randi 0, #@food[0]

    @food[x][y] = 0.5
  
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
    agent\update dt, @ if agent.update

scene.draw = =>
  for x = 0, #@food
    for y = 0, #@food[0]
      love.graphics.setColor 255 - @food[x][y] * 255, 255 - @food[x][y] * 255, 255 - @food[x][y] * 255
      love.graphics.rectangle "fill", x * 32, y * 32, 32, 32
      
      if @focused
        cx = math.floor @focused.hull.pos.x / 32
        cy = math.floor @focused.hull.pos.y / 32
      
        love.graphics.setColor 255, 0, 0
        love.graphics.rectangle "fill", cx * 32, cy * 32, 32, 32
  
  for agent in *@agents
    agent\draw! if agent.draw
      
  if @focused
    @focused.brain\draw @focused.hull.pos.x, @focused.hull.pos.y
    
    with love.graphics
      .setColor 255, 0, 0, 200
      .rectangle "line", @focused.hull.pos.x - @focused.hull.radius * 2, @focused.hull.pos.y - @focused.hull.radius * 2, @focused.hull.radius * 4, @focused.hull.radius * 4
  
  

scene.press = (key) =>
  if key == "space"
    for _ = 1, 1
      @spawn!

scene
