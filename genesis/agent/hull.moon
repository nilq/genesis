hull = {}

hull.make = (x, y) ->
  hull = {}

  with hull
    .pos        = {:x, :y}
    .health     = 1
    .radius     = 10
    .angle      = math.random -math.pi, math.pi
    .appendages = {}
    .color      = {
      math.random 0, 255
      math.random 0, 255
      math.random 0, 255
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

      .setColor @color
      .circle "fill", @pos.x, @pos.y, @radius
      
      .setColor 0, 0, 0
      .circle "line", @pos.x, @pos.y, @radius

  hull

hull
