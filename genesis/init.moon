scene = {}

agent = require "genesis/agent"

scene.load = =>
  math.randomseed os.time!
  @agents = {}
  
  for _ = 1, 100
    @spawn!
  
scene.spawn = =>
  @agents[#@agents + 1] = agent.agent!

scene.update = (dt) =>
  for agent in *@agents
    agent\update dt if agent.update

scene.draw = =>
  for agent in *@agents
    agent\draw! if agent.draw

scene
