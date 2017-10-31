path = "genesis/agent/"

hull  = require path .. "hull"
brain = require path .. "brain"

speed       = 0.5
boost_speed = 2

agent = ->
  agent = {}

  x = math.random 0, love.graphics.getWidth!
  y = math.random 0, love.graphics.getHeight!

  with agent
    .hull  = hull.make x, y
    .brain = brain.dwraonn.make!
    
    .wheel_l = 0
    .wheel_r = 0

    .out = {}
    for i = 0, brain.settings.outputs
      .out[i] = 0

    .inp = {}
    for i = 0, brain.settings.inputs
      .inp[i] = 0

  agent.update = (dt) =>
    @hull\update dt

    -- higher
    @brain\tick @inp, @out

    @wheel_l = @out[1]
    @wheel_r = @out[2]

    -- movement
    whp1 = { -- wheel position
      @hull.radius * (math.cos @hull.angle - math.pi / 4) + @hull.pos.x
      @hull.radius * (math.sin @hull.angle - math.pi / 4) + @hull.pos.y
    }

    whp2 = { -- wheel position
      @hull.radius * (math.cos @hull.angle + math.pi / 4) + @hull.pos.x
      @hull.radius * (math.sin @hull.angle + math.pi / 4) + @hull.pos.y
    }
    
    boost_l = speed * @wheel_l
    boost_r = speed * @wheel_r

    if @boosting
      boost_l *= boost_speed
      boost_r *= boost_speed

    vv1 = {
      boost_l * (math.cos math.atan2 whp1[2] - @hull.pos.y, whp1[1] - @hull.pos.x)
      boost_l * (math.sin math.atan2 whp1[2] - @hull.pos.y, whp1[1] - @hull.pos.x)
    }

    vv2 = {
      boost_r * (math.cos math.atan2 whp2[2] - @hull.pos.y, whp2[1] - @hull.pos.x)
      boost_r * (math.sin math.atan2 whp2[2] - @hull.pos.y, whp2[1] - @hull.pos.x)
    }

    @hull.angle = math.atan2 vv1[2] + vv2[2], vv1[1] + vv2[1]

    @hull.pos.x += vv1[1]
    @hull.pos.y += vv1[2]

    @hull.pos.x += vv2[1]
    @hull.pos.y += vv2[2]

    @hull.pos.x %= love.graphics.getWidth!
    @hull.pos.y %= love.graphics.getHeight!

  agent.draw = =>
    @hull\draw!

  agent

{
  :agent
  :hull
}
