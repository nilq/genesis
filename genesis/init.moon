scene = {}

agents_max = 30

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
  @agents[#@agents + 1] = agent.make_agent!
  
scene.put = (b) =>
  @agents[#@agents + 1] = b

scene.update = (dt) =>
  @count += 1

  @spawn! if #@agents < agents_max

  if @count % 200 == 0
    if 0.5 > util.randf 0, 1
      @spawn!
    else
      @put @agents[math.random 1, #@agents]\crossover_baby @agents[math.random 1, #@agents]
  
  if @count % 4 == 0
    for x = 0, #@food
      for y = 0, #@food[0]
        @food[x][y] -= 0.0001
  
  if @count % 120 == 0
    for _ = 0, 3
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
        
  if love.mouse.isDown 2
    if @focused
      x = love.mouse.getX!
      y = love.mouse.getY!

      for a in *@agents
        if (util.distance {x, y}, {a.hull.pos.x, a.hull.pos.y}) < a.hull.radius
          b = @focused\crossover_baby a, {:x, :y}
          @put b
          @focused = nil
          return
        
  for agent in *@agents
    agent\update dt, @ if agent.update
  
  for i = 1, #@agents
    continue unless @agents[i]

    if @agents[i].health <= 0
      dying = @agents[i]
      @agents[i].dead = true

      num_around = 0
      for j = 1, #@agents
        continue if j == i

        ag = @agents[j]

        if ag.health > 0
          d = util.distance {ag.hull.pos.x, ag.hull.pos.y}, {dying.hull.pos.x, dying.hull.pos.y}

          if d < 120
            num_around += 1

      if num_around > 0
        for j = 1, #@agents
          continue if j == i

          ag = @agents[j]

          d = util.distance {ag.hull.pos.x, ag.hull.pos.y}, {dying.hull.pos.x, dying.hull.pos.y}

          if d < 120
            ag.health    += 3 * (1 - ag.herb) ^ 2 / num_around
            ag.rep_count -= 2 * (1 - ag.herb) ^ 2 / num_around

            ag.health = 2 if ag.health > 2

      table.remove @agents, i

scene.draw = =>
  for x = 0, #@food
    for y = 0, #@food[0]
      love.graphics.setColor 0, 0, 0, @food[x][y] * 190
      love.graphics.rectangle "fill", x * 32, y * 32, 32, 32
      
      if @focused
        cx = math.floor @focused.hull.pos.x / 32
        cy = math.floor @focused.hull.pos.y / 32
      
        love.graphics.setColor 255, 0, 0
        love.graphics.rectangle "fill", cx * 32, cy * 32, 32, 32
  
  for agent in *@agents
    agent\draw! if agent.draw
      
    if @focused
      if agent.tag == @focused.tag
        with love.graphics
          .setColor 0, 0, 255, 200
          .rectangle "line", agent.hull.pos.x - agent.hull.radius * 2, agent.hull.pos.y - agent.hull.radius * 2, agent.hull.radius * 4, agent.hull.radius * 4

  if @focused
    @focused.brain\draw @focused.hull.pos.x, @focused.hull.pos.y

    with love.graphics
      .setColor 255, 0, 0, 200
      .rectangle "line", @focused.hull.pos.x - @focused.hull.radius * 2, @focused.hull.pos.y - @focused.hull.radius * 2, @focused.hull.radius * 4, @focused.hull.radius * 4

scene.press = (key) =>
  if key == "space"
    for _ = 1, 1
      @spawn!
      
  if key == "return"
    for _ = 1, 25
      @spawn!
      
  if key == "tab"
    for _ = 0, 1000
      @update 1
      
scene
