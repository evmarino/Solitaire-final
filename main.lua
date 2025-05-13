-- main.lua 
-- Evelyn Marino - CMPM 121 : Solitaire Project 2

io.stdout:setvbuf("no")

require "card"
local Vector       = require "vector"
local GrabberClass = require "grabber"
local Snap         = require "snap"
local mouse        = require "mouse"

local GameState = { PLAYING = 1, WON = 2 }
local game = { state = GameState.PLAYING }

-- shuffle table
local function shuffle(t)
  for i = #t, 2, -1 do
    local j = love.math.random(i)
    t[i], t[j] = t[j], t[i]
  end
end

--find index of value
function table.indexOf(t, val)
  for i, v in ipairs(t) do
    if v == val then return i end
  end
  return nil
end

-- draw one card from the deck
local function drawOneFromDeck()
  return table.remove(fullDeck)
end

--  7 piles
local function dealTableau()
  for col = 1, 7 do
    tableauColumns[col] = {}
    local pt = Snap.stackPoints[col]
    for row = 1, col do
      local card = drawOneFromDeck()
      card.column = col
      card.position = Vector(pt.x, pt.y + (row - 1) * 20)
      table.insert(tableauColumns[col], card)
      table.insert(cardTable, card)
    end
    -- flips top card
    tableauColumns[col][#tableauColumns[col]].faceUp = true
  end
end

-- checks for a win condition
local function checkWin()
  local count = 0
  for _, pile in pairs(foundations) do
    count = count + #pile
  end
  if count == 52 then
    game.state = GameState.WON
  end
end

-- starts/resets game
local function startGame()
  game.state = GameState.PLAYING


  foundations = { ["♥"] = {}, ["♦"] = {}, ["♣"] = {}, ["♠"] = {} }

  -- build/shuffle deck
  local suits = {"♥","♦","♣","♠"}
  local ranks = {"A","2","3","4","5","6","7","8","9","10","J","Q","K"}
  fullDeck = {}
  for _,s in ipairs(suits) do
    for _,r in ipairs(ranks) do
      table.insert(fullDeck, CardClass:new(0,0,s,r))
    end
  end
  shuffle(fullDeck)


  tableauColumns = {}
  cardTable      = {}
  discardPile    = {}
  drawPile       = {}

  dealTableau()

  -- leftover cards go to draw pile
  local pick1 = Snap.cardPick[1]
  for _, c in ipairs(fullDeck) do
    c.faceUp   = false
    c.position = Vector(pick1.x, pick1.y)
    table.insert(cardTable, c)
    table.insert(drawPile, c)
  end
  fullDeck = {}
end

function love.load()
  love.window.setMode(960, 640)
  love.graphics.setBackgroundColor(0.698, 1, 0.4)

  grabber = GrabberClass:new()
  Snap:load()
  startGame()
end

function love.mousepressed(x, y, button)
  if button ~= 1 then return end
  
  if game.state == GameState.WON then
    
    --play again button
    local w, h = love.graphics.getDimensions()
    local btnW, btnH = 140, 40
    local bx, by = (w - btnW)/2, h * 0.55
    if x >= bx and x <= bx + btnW
       and y >= by and y <= by + btnH
    then
      startGame()
      return
    end
  end
  -- reset button 
  if x >= 30 and x <= 70 and y >= 365 and y <= 395 then
    startGame()
    return
  end

  -- draw/waste
  local pick1 = Snap.cardPick[1]
  if x > pick1.x and x < pick1.x + 50
     and y > pick1.y and y < pick1.y + 70 then
    if #drawPile > 0 then
      local count = math.min(3, #drawPile)
      for i = 1, count do
        local c = table.remove(drawPile)
        c.faceUp = true
        local pick2 = Snap.cardPick[2]
        c.position = Vector(pick2.x + (i - 1) * 20, pick2.y)
        table.insert(discardPile, c)
        table.insert(cardTable, c)
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
  if game.state == GameState.PLAYING then
    grabber:update()
    mouse.checkForMouseMoving(grabber)
    checkWin()
  end
end

function love.draw()
  local held = grabber.heldCards or {}

  -- draw tableau, not held cards 
  for col = 1, 7 do
    local pt = Snap.stackPoints[col]
    for row, c in ipairs(tableauColumns[col]) do
      if not table.indexOf(held, c) then
        c.position = Vector(pt.x, pt.y + (row - 1) * 20)
        c:draw()
      end
    end
  end

  -- draw foundations
  for suit, pile in pairs(foundations) do
    local pt = Snap.foundationPoints[suit]
    for i, c in ipairs(pile) do
      if not table.indexOf(held, c) then
        c.position = Vector(pt.x, pt.y + (i - 1) * 20)
        c:draw()
      end
    end
  end

  --discard pile
  for i = math.max(1, #discardPile - 2), #discardPile do
    local c = discardPile[i]
    if not table.indexOf(held, c) then
      c:draw()
    end
  end

  -- draw pile 
  if #drawPile > 0 then
    local pick1 = Snap.cardPick[1]
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", pick1.x, pick1.y, 50, 70, 6, 6)
    love.graphics.setColor(1, 1, 1)
  end

  -- slots
  Snap:draw()

  -- held cards
  for _, c in ipairs(grabber.heldCards or {}) do c:draw() end

  -- win title
if game.state == GameState.WON then

  local w, h = love.graphics.getDimensions()

  love.graphics.setColor(0, 0, 0, 0.7)
  love.graphics.rectangle("fill", 0, 0, w, h)

  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(
    "You Win!",
    0,
    h * 0.45,
    w,
    "center"
  )
local btnW, btnH = 140, 40
local w, h = love.graphics.getDimensions()
local bx, by = (w - btnW)/2, h * 0.55


love.graphics.setColor(1, 1, 1)
love.graphics.rectangle("fill", bx, by, btnW, btnH, 6, 6)

love.graphics.setColor(0, 0, 0)
love.graphics.printf("Play Again", bx, by + 10, btnW, "center")
love.graphics.setColor(1, 1, 1)
end
love.graphics.setColor(0, 0, 0)
love.graphics.rectangle("line", 30, 365, 40, 30, 4, 4)
love.graphics.print("Reset", 33, 375)
love.graphics.setColor(1, 1, 1)
end 

function love.keypressed(key)
  if key == "w" then
    game.state = GameState.WON
  end
end

