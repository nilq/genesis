hull = {}

hull.make = (x, y) ->
  hull = {}

  with hull
    .pos        = {:x, :y}
    .health     = 1
    .radius     = 10
    .angle      = math.random -math.pi, math.pi
    .appendages = {}
    .hybrid     = {}
    .color      = {
      util.randf 0, 255
      util.randf 0, 255
      util.randf 0, 255
    }
    .color_race = {
      util.randf 0, 255
      util.randf 0, 255
      util.randf 0, 255
    }

  hull.update = (dt) =>
    for appendage in *@appendages
      appendage\update dt if appendage.update

    @pos.x %= love.graphics.getWidth!
    @pos.y %= love.graphics.getHeight!
    
  hull.draw = =>
    with love.graphics
      for appendage in *@appendages
        appendage\draw! if appendage.draw
          
      .setColor @color_race
      .circle "fill", @pos.x, @pos.y, @radius
      
      i = 1
      for h in *@hybrid
        .setColor h.color_race
        .arc "fill", @pos.x, @pos.y, @radius, @angle + ((math.pi * 2) / (#@hybrid + 1)) * i, @angle + ((math.pi * 2) / (#@hybrid + 1)) * (i + 1)
        i += 1
      
      .setColor 0, 0, 0
      .circle "line", @pos.x, @pos.y, @radius
      
      .setColor @color
      .circle "line", @pos.x, @pos.y, @radius * 1.5

      .setColor @color
      .circle "line", @pos.x, @pos.y, @radius * 1.5 + 1
      
      .setColor @color
      .circle "line", @pos.x, @pos.y, @radius * 1.5 + 2

  hull

hull
