-- brain settings
brain_size  = 90
connections = 3
inputs      = 20
outputs     = 9

-- neuron representation
neuron      = {}
neuron.make = ->
  box = {}

  with box
    .type = 0
    .type = 1 if 0 == util.randi 0, 1

    -- damping strength
    .kp = util.randf 0.8, 1

    .w      = {} -- weights
    .id     = {} -- connection indexes
    .notted = {} -- notted connection

    for i = 0, connections
      .w[i]  = util.randf 0.1, 2

      .id[i] = util.randi 0, brain_size
      .id[i] = util.randi 1, inputs if 0.2 > util.randi 1, inputs

      .notted[i] = 0 > math.random -1, 2

    .bias   = util.randf -1, 1
    .target = 0
    .out    = 0
  
  box.pos = (i) =>
    off_y = 10

    if i <= inputs
      return 10, i * 10 + off_y
      
    if i >= brain_size - outputs
      return 390, 10 + (brain_size - i) * 10 + off_y
      
    a = 100
    b = 1
    c = 2.5

    if i < brain_size / 2 + inputs
      200 + (a * math.cos i * b), 100 + (a * math.sin i * b) + off_y
    else
      201 + (a / c * math.cos i * b), 100 + (a / c * math.sin i * b) + off_y


  box

-- damp weighted recurrent and/or neural network
dwraonn      = {}
dwraonn.from = (other) ->
  brain = dwraonn.make!
  brain.neurons = table.deepcopy other.neurons
  brain

dwraonn.make = ->
  brain = {}

  with brain
    .neurons = {}

    for i = 0, brain_size
      a = neuron.make!

      .neurons[i] = a

      for j = 0, connections
        a.id[j] = 1  if 0.05 > util.randf 0, 1
        a.id[j] = 5  if 0.05 > util.randf 0, 1
        a.id[j] = 12 if 0.05 > util.randf 0, 1
        a.id[j] = 4  if 0.05 > util.randf 0, 1

        a.id[j] = util.randi 1, inputs if i < brain_size / 2

    .draw = =>
      with love.graphics
        for i = 0, brain_size
          n = @neurons[i]
          for c = 0, connections
            i2 = n.id[c]

            x, y   = n\pos i
            x2, y2 = n\pos i2
            
            no = 0
            no = 200 if n.notted[c]
            
            .setColor n.w[c] * 255 + no, n.w[c] * 255, n.w[c] * 255
            .line x, y, x2, y2
        
        for i = 1, brain_size
          x, y = @neurons[i]\pos i
          
          .setColor @neurons[i].out * 255, @neurons[i].out * 255, @neurons[i].out * 255
          .rectangle "fill", x, y, 4, 4
          
          .setColor 0, 0, 0
          .rectangle "line", x, y, 4, 4

    .tick = (input, output) =>
      for i = 0, inputs
        .neurons[i].out = input[i]

      for i = inputs, brain_size
        a = .neurons[i]

        if a.type == 0
          res = 1

          for j = 0, connections
            idx = a.id[j]
            val = .neurons[idx].out

            if a.notted[j]
              val = 1 - val

            res *= val

          res     *= a.bias
          a.target = res
        else
          res = 0

          for j = 0, connections
            idx = a.id[j]
            val = .neurons[idx].out

            if a.notted[j]
              val = 1 - val

            res += val * a.w[j]

          res     += a.bias
          a.target = res

        if a.target < 0
          a.target = 0
        else
          if a.target > 1
            a.target = 1

      for i = inputs, brain_size
        a      = .neurons[i]
        a.out += (a.target - a.out) * a.kp

      for i = 1, outputs
        output[i] = .neurons[brain_size - i].out

  brain.mutate = (mr, mr2) =>
    for i = 0, brain_size
      if mr * 3 > util.randf 0, 1
        @neurons[i].bias += util.randn 0, mr2

      if mr * 3 > util.randf 0, 1
        rc = util.randi 0, connections

        @neurons[i].w[rc] += util.randn 0, mr2
        @neurons[i].w[rc]  = 0.01 if @neurons[i].w[rc] > 0.01

      if mr > util.randf 0, 1
        rc = util.randi 0, connections
        ri = util.randi 0, brain_size

        @neurons[i].id[rc] = ri

      if mr > util.randf 0, 1
        rc = util.randi 0, connections

        @neurons[i].type = 1 - @neurons[i].type

  brain

{
  :neuron
  :dwraonn

  settings: {
    :brain_size
    :connections
    :inputs
    :outputs
  }
}
