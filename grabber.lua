-- grabber.lua
local Vector = require "vector"
local Snap   = require "snap"

local rankOrder = { A=1, ["2"]=2, ["3"]=3, ["4"]=4,
                    ["5"]=5, ["6"]=6, ["7"]=7, ["8"]=8,
                    ["9"]=9, ["10"]=10, J=11, Q=12, K=13 }
local isRed     = { ["♥"]=true, ["♦"]=true }

local function distance(a,b)
  return ((a.x-b.x)^2 + (a.y-b.y)^2)^0.5
end

local function removeSlice(col,idx)
  for i=#col,idx,-1 do table.remove(col,i) end
end

local function canGoToFoundation(card,pile)
  if #pile==0 then return card.rank=="A" end
  return rankOrder[card.rank]==rankOrder[pile[#pile].rank]+1
end

local Grabber = {}
function Grabber:new()
  return setmetatable({ heldCards=nil, originColumn=nil, originIdx=nil, dragOffset=nil, currentMousePos=nil },{__index=Grabber})
end

function Grabber:update()
  local mx,my = love.mouse.getX(), love.mouse.getY()
  self.currentMousePos = Vector(mx, my)
  if self.heldCards then
    local base = self.currentMousePos - self.dragOffset
    for i, c in ipairs(self.heldCards) do
      c.position = Vector(base.x, base.y + (i-1)*20)
    end
    if not love.mouse.isDown(1) then self:release() end
  end
end

function Grabber:grab()
  self.grabPos = self.currentMousePos
  for i=#cardTable,1,-1 do
    local c = cardTable[i]
    if c.faceUp and c:isClicked(self.grabPos.x, self.grabPos.y) then
      if c.column then
        local col = tableauColumns[c.column]
        for j,v in ipairs(col) do if v==c then self.originIdx=j break end end
        self.originColumn = c.column
        self.heldCards    = {}
        for j=self.originIdx,#col do table.insert(self.heldCards, col[j]) end
      else
        self.originColumn = nil
        self.originIdx    = nil
        self.heldCards    = {c}
      end
      self.dragOffset = self.grabPos - c.position
      self.heldCards[1].originalPosition = c.position
      for _, hc in ipairs(self.heldCards) do
        for k=#cardTable,1,-1 do if cardTable[k]==hc then table.remove(cardTable,k) end end
        table.insert(cardTable, hc)
      end
      break
    end
  end
end

function Grabber:release()
  local run = self.heldCards if not run then return end
  local snapped = false

  -- Foundationals
  if #run==1 then
    local c = run[1]
    local pt = Snap.foundationPoints[c.suit]
    local pile = foundations[c.suit]
    if distance(c.position, pt)<Snap.snapRad and canGoToFoundation(c,pile) then
      if self.originColumn then
        removeSlice(tableauColumns[self.originColumn], self.originIdx)
        local nt = tableauColumns[self.originColumn][#tableauColumns[self.originColumn]]
        if nt and not nt.faceUp then nt.faceUp = true end
      else
        table.remove(discardPile)
        for idx, dc in ipairs(discardPile) do
          dc.position = Vector(
            Snap.cardPick[2].x + (idx-1)*20,
            Snap.cardPick[2].y
          )
        end
      end
      table.insert(pile, c)
      c.column = nil
      c.position = Vector(pt.x, pt.y + (#pile-1)*20)
      snapped = true
    end
  end

--Tableau 
  if not snapped then
    for col=1,7 do
      local pt     = Snap.stackPoints[col]
      local target = Vector(pt.x, pt.y + #tableauColumns[col] * 20)
      if distance(run[1].position, target)<Snap.snapRad then
        local dest = tableauColumns[col]
        local canPlace
        if #dest==0 then
          canPlace = (run[1].rank=="K")
        else
          local top = dest[#dest]
          canPlace = 
            rankOrder[top.rank]==rankOrder[run[1].rank]+1
            and (isRed[top.suit]~=isRed[run[1].suit])
        end
        if canPlace then
          if self.originColumn then
            removeSlice(tableauColumns[self.originColumn], self.originIdx)
            local nt = tableauColumns[self.originColumn][#tableauColumns[self.originColumn]]
            if nt and not nt.faceUp then nt.faceUp = true end
          else
            table.remove(discardPile)
          end
          for i, c in ipairs(run) do
            c.column = col
            table.insert(dest, c)
            c.position = Vector(
              pt.x,
              pt.y + (#dest - #run + i-1)*20
            )
          end
          snapped = true
          break
        end
      end
    end
  end

--Resets position
  if not snapped then
    for i, c in ipairs(run) do
      if i==1 then
        c.position = run[1].originalPosition
      else
        c.position = Vector(
          run[1].originalPosition.x,
          run[1].originalPosition.y + (i-1)*20
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
