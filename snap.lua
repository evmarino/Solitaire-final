-- snap.lua
require "vector"
local Snap = {}

function Snap:load()
  
  self.stackPoints = {}
  for i=1,7 do
    table.insert(self.stackPoints,
    Vector(100 + (i-1)*120, 50)) 
  end

  -- foundational slots
  self.foundationPoints = {}
  for i=1,4 do
    self.foundationPoints[ ({ "♥","♦","♣","♠" })[i] ] =
      Vector(300 + (i-1)*100, 400)
  end

  self.cardPick = {
    Vector(30, 400),  -- draw pile
    Vector(30, 490)   -- waste pile
  }

  self.snapRad = 150
end

function Snap:draw()
  -- stacked slots
  for _, pt in ipairs(self.stackPoints) do
    love.graphics.setColor(1,1,1,0.1)
    love.graphics.rectangle("fill", pt.x, pt.y, 50,70,6,6)
    love.graphics.setColor(0,0,0,0.2)
    love.graphics.rectangle("line", pt.x, pt.y, 50,70,6,6)
  end

  --foundational slots
  for _, pt in pairs(self.foundationPoints) do
    love.graphics.setColor(1,1,1,0.1)
    love.graphics.rectangle("fill", pt.x, pt.y, 50,70,6,6)
    love.graphics.setColor(0,0,0,0.2)
    love.graphics.rectangle("line", pt.x, pt.y, 50,70,6,6)
  end

  -- draw / waste
  for _, pt in ipairs(self.cardPick) do
    love.graphics.setColor(1,1,1,0.1)
    love.graphics.rectangle("fill", pt.x, pt.y, 50,70,6,6)
    love.graphics.setColor(0,0,0,0.2)
    love.graphics.rectangle("line", pt.x, pt.y, 50,70,6,6)
  end
end

return Snap
