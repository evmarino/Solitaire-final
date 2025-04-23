-- Evelyn Marino - CMPM 121 : Solitaire Project - 4/12/2025

io.stdout:setvbuf("no")

require "card"
local Vector       = require "vector"
local GrabberClass = require "grabber"
local Snap         = require "snap"
local mouse        = require "mouse"

-- shuffle table in place
local function shuffle(t)
  for i = #t, 2, -1 do
    local j = love.math.random(i)
    t[i], t[j] = t[j], t[i]
  end
end

-- find index of value
function table.indexOf(t, val)
  for i, v in ipairs(t) do
    if v == val then return i end
  end
  return nil
end

-- draws one card from the full deck
local function drawOneFromDeck()
  return table.remove(fullDeck)
end

-- deals 7 piles
local function dealTableau()
  for col = 1, 7 do
    tableauColumns[col] = {}
    for row = 1, col do
      local card = drawOneFromDeck()
      card.column = col
      local pt = Snap.stackPoints[col]
      card.position = Vector(pt.x, pt.y + (row - 1) * 20)
      table.insert(tableauColumns[col], card)
      table.insert(cardTable, card)
    end
    -- flips the top card
    local top = tableauColumns[col][#tableauColumns[col]]
    top.faceUp = true
  end
end

function love.load()
  love.window.setMode(960, 640)
  love.graphics.setBackgroundColor(0.698, 1, 0.4)

  grabber = GrabberClass:new()
  Snap:load()

  -- initialize foundations as empty
  foundations = { ["♥"] = {}, ["♦"] = {}, ["♣"] = {}, ["♠"] = {} }

  -- build /shuffle the full deck
  local suits = { "♥", "♦", "♣", "♠" }
  local ranks = { "A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K" }
  fullDeck = {}
  for _, suit in ipairs(suits) do
    for _, rank in ipairs(ranks) do
      table.insert(fullDeck, CardClass:new(0, 0, suit, rank))
    end
  end
  shuffle(fullDeck)

  -- piles
  tableauColumns = {}
  cardTable      = {}
  discardPile    = {}
  drawPile       = {}


  dealTableau()

  -- leftover cards go to draw pile
  for _, card in ipairs(fullDeck) do
    card.faceUp   = false
    card.position = Vector(Snap.cardPick[1].x, Snap.cardPick[1].y)
    table.insert(cardTable, card)
    table.insert(drawPile, card)
  end
  fullDeck = {}
end

-- returns the top face up card of tableau
local function getTopCard(col)
  local column = tableauColumns[col]
  if not column then return nil end
  for i = #column, 1, -1 do
    if column[i].faceUp then return column[i] end
  end
end

function love.mousepressed(x, y, button)
  if button ~= 1 then return end

  -- draw / waste logic
  local pick1 = Snap.cardPick[1]
  if x > pick1.x and x < pick1.x + 50
      and y > pick1.y and y < pick1.y + 70 then
    if #drawPile > 0 then
      local count = math.min(3, #drawPile)
      for i = 1, count do
        local card = table.remove(drawPile)
        card.faceUp = true
        card.position = Vector(
          Snap.cardPick[2].x + (i - 1) * 20,
          Snap.cardPick[2].y
        )
        table.insert(discardPile, card)
        table.insert(cardTable, card)    -- <<< add this!
      end
    elseif #discardPile > 0 then
      for i = #discardPile, 1, -1 do
        local c = discardPile[i]
        c.faceUp = false
        c.position = Vector(pick1.x, pick1.y)
        table.insert(drawPile, c)
      end
      discardPile = {}
    end

    return
  end
  grabber:grab()
end

function love.update(dt)
  grabber:update()
  mouse.checkForMouseMoving(grabber)
end

function love.draw()
  -- 7 piles
  for col = 1, 7 do
    local pt = Snap.stackPoints[col]
    for row, card in ipairs(tableauColumns[col]) do
      -- reposition every frame to stackPoints + 20px per row
      card.position = Vector(
        pt.x,
        pt.y + (row - 1) * 20
      )
      card:draw()
    end
  end

  --foundationals (A -> K)
  for suit, pile in pairs(foundations) do
    local pt = Snap.foundationPoints[suit]
    for i, card in ipairs(pile) do
      card.position = Vector(
        pt.x,
        pt.y + (i - 1) * 20
      )
      card:draw()
    end
  end

  -- discard pile
  for i = math.max(1, #discardPile - 2), #discardPile do
    discardPile[i]:draw()
  end

  -- draw pile puts back if any remain
  if #drawPile > 0 then
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle(
      "fill",
      Snap.cardPick[1].x, Snap.cardPick[1].y,
      50, 70, 6, 6
    )
    love.graphics.setColor(1, 1, 1, 1)
  end

  -- empties
  Snap:draw()
end

