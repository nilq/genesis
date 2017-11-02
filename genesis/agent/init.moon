path = "genesis/agent/"

hull  = require path .. "hull"
brain = require path .. "brain"

speed       = 0.5
boost_speed = 2

rep_rate = (herb, c=2, h=2) ->
  herb * (util.randf c - 0.1, h + 0.1) + (1 - herb) * util.randf c - 0.1, h + 0.1

make_agent = ->
  agent = {}

  x = math.random 0, love.graphics.getWidth!
  y = math.random 0, love.graphics.getHeight!

  with agent
    .hull  = hull.make x, y
    .brain = brain.dwraonn.make!
    
    .dead = false
    
    .tag = (math.random -100, 100) .. math.random -1000, 1000

    .wheel_l = 0
    .wheel_r = 0

    .health    = 1 + util.randf 0, 0.1
    .herb      = util.randf 0, 1
    .rep_count = rep_rate .herb
    
    .sound_mul = 0
    .spike_len = 0
    
    -- internal time system
    .clock_f1 = util.randf 5, 100
    .clock_f2 = util.randf 5, 100
    
    .mut_rate1 = 0.003
    .mut_rate2 = 0.05
    
    .gen_count = 0

    .out = {}
    for i = 0, brain.settings.outputs
      .out[i] = 0

    .inp = {}
    for i = 0, brain.settings.inputs
      .inp[i] = 0
      
  agent.eat = (scene) =>
    cx = math.floor @hull.pos.x / 32
    cy = math.floor @hull.pos.y / 32

    food = scene.food[cx][cy]

    if food > 0 and @health < 2 -- 2 is maxima
      itk       = math.min food, 0.0325 -- intake constant
      speed_mul = (1 - (math.abs @wheel_l + math.abs @wheel_l) / 2) / 2 + 0.5

      itk *= @herb^2 * speed_mul

      @health    += itk
      @rep_count -= 3 * itk

      scene.food[cx][cy] -= math.min food, 0.003

  agent.think = (scene) =>
    cx = math.floor @hull.pos.x / 32
    cy = math.floor @hull.pos.y / 32

    @inp[9] = scene.food[cx][cy] / 0.5

    @inp[11] = util.cap @health / 2
    
    @inp[17] = math.abs math.sin scene.count / @clock_f1
    @inp[18] = math.abs math.sin scene.count / @clock_f2
    
    -- eyes: distance sensor, colors
    p1, r1, g1, b1 = 0, 0, 0, 0
    p2, r2, g2, b2 = 0, 0, 0, 0
    p3, r3, g3, b3 = 0, 0, 0, 0
    
    sight = 150
    
    pi8  = math.pi / 8 / 2
    pi38 = pi8 * 3
    
    blood = 0
    
    for i = 1, #scene.agents
      agent = scene.agents[i]
      continue if agent == @
        
      x1 = @hull.pos.x < agent.hull.pos.x - sight
      x2 = @hull.pos.x > agent.hull.pos.x + sight

      y1 = @hull.pos.y > agent.hull.pos.y + sight
      y2 = @hull.pos.y < agent.hull.pos.y - sight
      
      sound_acc = 0
      smell_acc = 0
      hear_acc  = 0
      
      continue if x1 or x2 or y1 or y2
        
      d = util.distance {@hull.pos.x, @hull.pos.y}, {agent.hull.pos.x, agent.hull.pos.y}
    
      if d < sight
        smell_acc += 0.3 * (sight - d) / sight
        sound_acc += 0.4 * (sight - d) / sight
        hear_acc  += agent.sound_mul * (sight - d) / sight
        
        angle = math.atan2 (@hull.pos.y - agent.hull.pos.y), (@hull.pos.x - agent.hull.pos.x)

        l_eye_ang = @hull.angle - pi8
        r_eye_ang = @hull.angle + pi8

        back_angle = @hull.angle + math.pi
        forw_angle = @hull.angle
        
        l_eye_ang  += 2 * math.pi if l_eye_ang  < -math.pi
        r_eye_ang  -= 2 * math.pi if r_eye_ang  >  math.pi
        back_angle -= 2 * math.pi if back_angle >  math.pi
          
        diff1 = l_eye_ang - angle
        diff1 = 2 * math.pi - math.abs diff1 if math.pi < math.abs diff1
        diff1 = math.abs diff1

        diff2 = r_eye_ang - angle
        diff2 = 2 * math.pi - math.abs diff2 if math.pi < math.abs diff2
        diff2 = math.abs diff2

        diff3 = back_angle - angle
        diff3 = 2 * math.pi - math.abs diff3 if math.pi < math.abs diff3
        diff3 = math.abs diff3

        diff4 = forw_angle - angle
        diff4 = 2 * math.pi - math.abs forw_angle if math.pi < math.abs forw_angle
        diff4 = math.abs diff4
        
        if diff1 < pi38
          mul1 = 2 *((pi38 - diff1) / pi38) * ((sight - d) / sight)

          p1 += mul1 * (d / sight)

          r1 += mul1 * agent.hull.color[1]
          g1 += mul1 * agent.hull.color[2]
          b1 += mul1 * agent.hull.color[3]
          
        if diff2 < pi38
              mul2 = 2 *((pi38 - diff1) / pi38) * ((sight - d) / sight)

              p2 += mul2 * (d / sight)

              r2 += mul2 * agent.hull.color[1]
              g2 += mul2 * agent.hull.color[2]
              b2 += mul2 * agent.hull.color[3]

        if diff3 < pi38
            mul3 = 2 *((pi38 - diff1) / pi38) * ((sight - d) / sight)

            p3 += mul3 * (d / sight)

            r3 += mul3 * agent.hull.color[1]
            g3 += mul3 * agent.hull.color[2]
            b3 += mul3 * agent.hull.color[3]
            
        if diff4 < pi38
          mul4 = 2 *((pi38 - diff1) / pi38) * ((sight - d) / sight) -- 2 == blood_sens

          blood += mul4 * (1 - agent.health / 2)  
          
        @inp[1] = util.cap p1
        @inp[2] = util.cap r1
        @inp[3] = util.cap g1
        @inp[4] = util.cap b1
        @inp[5] = util.cap p2
        @inp[6] = util.cap r2
        @inp[7] = util.cap g2
        @inp[8] = util.cap b2
        
        @inp[10] = util.cap sound_acc
        @inp[12] = util.cap smell_acc

        @inp[13] = util.cap p3
        @inp[14] = util.cap r3
        @inp[15] = util.cap g3
        @inp[16] = util.cap b3
        
        @inp[19] = util.cap hear_acc
        @inp[20] = util.cap blood
    
    ----------------------------------
    @brain\tick @inp, @out
    ----------------------------------
    
    @wheel_l = @out[1]
    @wheel_r = @out[2]

    @hull.color[1] = @out[3] * 255
    @hull.color[2] = @out[4] * 255
    @hull.color[3] = @out[5] * 255

    g = @out[6]
    if @spike_len < g
      @spike_len += 0.05
    else
      @spike_len = g

    @sound_mul = @out[8]

  agent.update = (dt, scene) =>
    @think scene
    @hull\update dt
    @eat scene

    -- starve
    loss = 0.0002 + 0.0001 * ((math.abs @wheel_r) + (math.abs @wheel_r)) / 2
    loss = 0.001 if @wheel_l < 0.1 and @wheel_r < 0.1

    if @boosting
      @health -= loss * 4
    else
      @health -= loss

    if scene.count % 2 == 0
      for i = 1, #scene.agents
        other = scene.agents[i]
        continue if other == @

        d = util.distance {@hull.pos.x, @hull.pos.y}, {other.hull.pos.x, other.hull.pos.y}

        if d < 2 * @hull.radius
          diff = math.atan2 other.hull.pos.y - @hull.pos.y, other.hull.pos.x - @hull.pos.x

          if math.pi / 8 > math.abs diff
            mult = 1
            mult = 2 if @boosting

            dmg = 0.5 * @spike_len * 2 * math.max (math.abs @wheel_l), math.abs @wheel_r

            other.health -= dmg

            @spike_len = 0

    if @rep_count < 0 and @health > 0.65
        scene\put @make_baby @mut_rate1, @mut_rate2
        @rep_count = rep_rate @herb

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
    with love.graphics
      --spike
      .setColor 255, 0, 0
      .line @hull.pos.x, @hull.pos.y, @hull.pos.x + (@spike_len * 3 * @hull.radius * math.cos @hull.angle), @hull.pos.y + (@spike_len * 3 * @hull.radius * math.sin @hull.angle)
      
      -- front eyes
      for j = -3, 3
        if j == 0
          continue

        .setColor 200, 200, 200

        eye_x = @hull.pos.x + @hull.radius * 3 * (math.cos @hull.angle + j * math.pi / 8)
        eye_y = @hull.pos.y + @hull.radius * 3 * (math.sin @hull.angle + j * math.pi / 8)

        .line @hull.pos.x, @hull.pos.y, eye_x, eye_y

        
      .setColor 200, 200, 200

      eye_pos1 = {
        x: @hull.pos.x + @hull.radius * 1.5 * (math.cos @hull.angle + math.pi + 3 * math.pi / 16)
        y: @hull.pos.y + @hull.radius * 1.5 * (math.sin @hull.angle + math.pi + 3 * math.pi / 16)
      }

      eye_pos2 = {
        x: @hull.pos.x + @hull.radius * 1.5 * (math.cos @hull.angle - math.pi - 3 * math.pi / 16)
        y: @hull.pos.y + @hull.radius * 1.5 * (math.sin @hull.angle - math.pi - 3 * math.pi / 16)
      }

      .line @hull.pos.x, @hull.pos.y, eye_pos1.x, eye_pos1.y
      .line @hull.pos.x, @hull.pos.y, eye_pos2.x, eye_pos2.y

      -- health arc
      .setColor 0, 200, 0
      .arc "fill", @hull.pos.x, @hull.pos.y, @hull.radius * 1.75, @hull.angle - math.pi * (@health / 2), @hull.angle + math.pi * (@health / 2)

    @hull\draw!

  agent.make_baby = (mr, mr2) =>
    baby = make_agent!
    
    baby.tag = @tag
    baby.hull.hybrid = @hull.hybrid
    
    -- behind
    baby.hull.pos = {
      x: @hull.pos.x + @hull.radius + util.randf -@hull.radius * 2, @hull.radius * 2
      y: @hull.pos.y + util.randf -@hull.radius * 2, @hull.radius * 2
    }

    baby.hull.color_race = @hull.color_race

    baby.hull.pos.x %= love.graphics.getWidth!
    baby.hull.pos.y %= love.graphics.getHeight!

    baby.gen_count = @gen_count + 1
    baby.rep_count = rep_rate baby.herb

    baby.mut_rate1 = @mut_rate1
    baby.mut_rate2 = @mut_rate2

    if .2 > util.randf 0, 1
      baby.mut_rate1 = util.randn @mut_rate1, 0.002

    if .2 > util.randf 0, 1
      baby.mut_rate2 = util.randn @mut_rate2, 0.05

    @mut_rate1 = 0.001 if @mut_rate1 < 0.001
    @mut_rate1 = 0.025 if @mut_rate1 < 0.025

    baby.herb = util.cap @herb, mr2 * 4

    baby.clock_f1 = @clock_f1
    baby.clock_f2 = @clock_f2

    if mr * 5 > util.randf 0, 1
      baby.clock_f1 = util.randf baby.clock_f1, mr2

    if mr * 5 > util.randf 0, 1
      baby.clock_f2 = util.randf baby.clock_f2, mr2

    baby.clock_f1 = 2 if baby.clock_f1 < 2
    baby.clock_f2 = 2 if baby.clock_f2 < 2

    baby.brain = brain.dwraonn.from @brain
    baby.brain\mutate mr, mr2

    baby

  agent.crossover_baby = (b, pos) =>
    baby = make_agent!
    
    baby.hull.pos = pos if pos

    baby.gen_count   = @gen_count

    for h in *b.hull.hybrid
      table.insert baby.hull.hybrid, h

    for h in *@hull.hybrid
      table.insert baby.hull.hybrid, h

    table.insert baby.hull.hybrid, b.hull

    baby.gen_count = b.gen_count if b.gen_count < baby.gen_count
    
    baby.clock_f1 = b.clock_f1
    baby.clock_f2 = b.clock_f2
    
    baby.herb      = b.herb

    baby.mut_rate1 = b.mut_rate1
    baby.mut_rate2 = b.mut_rate2

    baby.clock_f1 = @clock_f1 if 0.5 > util.randf 0, 1
    baby.clock_f2 = @clock_f2 if 0.5 > util.randf 0, 1

    baby.herb = @herb if 0.5 > util.randf 0, 1

    baby.mut_rate1 = @mut_rate1 if 0.5 > util.randf 0, 1
    baby.mut_rate2 = @mut_rate2 if 0.5 > util.randf 0, 1

    baby.brain = @brain\crossover b.brain
    
    baby

  agent

{
  :make_agent
  :hull
}
