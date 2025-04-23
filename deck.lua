local suits = {"♥", "♦", "♣", "♠"}
local ranks = {"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"}

local startX = 50
local startY = 50

cardTable = {}  -- make sure it's initialized

for s = 1, #suits do
  for r = 1, #ranks do
    local x = startX + (r - 1) * 20  -- position across the row
    local y = startY + (s - 1) * 30  -- each suit gets its own row
    table.insert(cardTable, CardClass:new(x, y, suits[s], ranks[r]))
  end
end
