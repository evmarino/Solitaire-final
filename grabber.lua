-- grabber.lua
local Vector = require "vector"
local Snap   = require "snap"


local rankOrder = { A = 1, ["2"] = 2, ["3"] = 3, ["4"] = 4, ["5"] = 5, ["6"] = 6, ["7"] = 7, ["8"] = 8, ["9"] = 9, ["10"] = 10, J = 11, Q = 12, K = 13 }
local isRed = { ["♥"] = true, ["♦"] = true }

local function distance(a, b)
  return ((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2) ^ 0.5
end


local function removeSlice(col, startIdx)
  for i = #col, startIdx, -1 do
    table.remove(col, i)
  end
end

local function canGoToFoundation(card, pile)
  if #pile == 0 then return card.rank == "A" end
  return rankOrder[card.rank] == rankOrder[pile[#pile].rank] + 1
end

local Grabber = {}
function Grabber:new()
  return setmetatable({
    currentMousePos = nil,
    grabPos = nil,
    heldCards = nil,
    dragOffset = nil,
    originColumn = nil,
    originIdx = nil
  }, { __index = Grabber })
end

function Grabber:update()
  local mx, my = love.mouse.getX(), love.mouse.getY()
  self.currentMousePos = Vector(mx, my)

  if self.heldCards then
    -- move stack
    local base = self.currentMousePos - self.dragOffset
    for i, card in ipairs(self.heldCards) do
      card.position = Vector(base.x, base.y + (i - 1) * 20)
    end
    -- drop
    if not love.mouse.isDown(1) then
      self:release()
    end
  end
end

function Grabber:grab()
  self.grabPos = self.currentMousePos

  for i = #cardTable, 1, -1 do
    local card = cardTable[i]
    if card.faceUp and card:isClicked(self.grabPos.x, self.grabPos.y) then
      if card.column then
        local col = tableauColumns[card.column]
        local idx
        for j, c in ipairs(col) do
          if c == card then idx = j end
        end
        self.originColumn = card.column
        self.originIdx    = idx
        self.heldCards    = {}
        for j = idx, #col do
          table.insert(self.heldCards, col[j])
        end
      else
        --single card in side deck
        self.originColumn = nil
        self.originIdx    = nil
        self.heldCards    = { card }
      end

      -- prepares drag
      self.dragOffset = self.grabPos - card.position

      self.heldCards[1].originalPosition = card.position

      -- bring to front
      for _, c in ipairs(self.heldCards) do
        for k = #cardTable, 1, -1 do
          if cardTable[k] == c then
            table.remove(cardTable, k)
          end
        end
        table.insert(cardTable, c)
      end
      break
    end
  end
end

function Grabber:release()
  local held = self.heldCards
  if not held then return end

  local snapped = false

  -- Foundations
  if #held == 1 then
    local c = held[1]
    for suit, pile in pairs(foundations) do
      local pt = Snap.foundationPoints[suit]
      if c.suit == suit
          and distance(c.position, pt) < Snap.snapRad
          and canGoToFoundation(c, pile)
      then
        -- remove from old pile
        if self.originColumn then
          removeSlice(tableauColumns[self.originColumn], self.originIdx)
          local newTop = tableauColumns[self.originColumn][#tableauColumns[self.originColumn]]
          if newTop and not newTop.faceUp then newTop.faceUp = true end
        else
          table.remove(discardPile)
          -- reposition the remaining waste cards
          for idx, dc in ipairs(discardPile) do
            dc.position = Vector(
              Snap.cardPick[2].x + (idx - 1) * 20,
              Snap.cardPick[2].y
            )
          end
        end

        -- add to foundation
        table.insert(pile, c)
        c.column   = nil
        c.position = Vector(pt.x, pt.y + (#pile - 1) * 20)
        snapped    = true
        break
      end
    end
  end

  -- Tableau movement
  if not snapped then
    for col = 1, 7 do
      local pt     = Snap.stackPoints[col]
      local target = Vector(pt.x, 100 + #tableauColumns[col] * 20)
      if distance(held[1].position, target) < Snap.snapRad then
        local dest = tableauColumns[col]
        local canPlace = false
        if #dest == 0 then
          canPlace = (held[1].rank == "K")
        else
          local top = dest[#dest]
          canPlace = (
            rankOrder[top.rank] == rankOrder[held[1].rank] + 1
            and (isRed[top.suit] ~= isRed[held[1].suit])
          )
        end
        if canPlace then
          -- removes from old pile
          if self.originColumn then
            removeSlice(tableauColumns[self.originColumn], self.originIdx)
            local newTop = tableauColumns[self.originColumn][#tableauColumns[self.originColumn]]
            if newTop and not newTop.faceUp then newTop.faceUp = true end
          else
            table.remove(discardPile)
            -- reposition the remaining waste cards
            for idx, dc in ipairs(discardPile) do
              dc.position = Vector(
                Snap.cardPick[2].x + (idx - 1) * 20,
                Snap.cardPick[2].y
              )
            end
          end

          -- attach heldCards to new t column
          for i, c in ipairs(held) do
            c.column = col
            table.insert(dest, c)
            c.position = Vector(
              pt.x,
              100 + (#dest - #held + i - 1) * 20
            )
          end
          snapped = true
        end
        break
      end
    end
  end

  -- reset if neither snapped
  if not snapped then
    for i, c in ipairs(held) do
      if i == 1 then
        c.position = held[1].originalPosition
      else
        c.position = Vector(
          held[1].originalPosition.x,
          held[1].originalPosition.y + (i - 1) * 20
        )
      end
    end
  end

  -- cleanup
  self.heldCards    = nil
  self.originColumn = nil
  self.originIdx    = nil
end

return Grabber

