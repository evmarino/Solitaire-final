require "vector" 

CardClass = {}

  CARD_STATE = {
  IDLE= 0, 
  MOUSE_OVER = 1,
  GRABBED = 2
  }
function CardClass:new(xPos,yPos, suit, rank)
  local card = {}
  local metadata = {__index = CardClass}
  setmetatable(card, metadata)
  
  card.position = Vector(xPos,yPos)
  card.size = Vector (50,70) 
  card.state = CARD_STATE.IDLE
  
  card.suit = suit
  card.rank = rank
  card.faceUp = false
  card.isDragging = false
  card.dragOffset = Vector(0,0)
  
  return card
end

function CardClass:update()
    
    
end
function CardClass:draw()
  if self.faceUp then
    love.graphics.setColor(1, 1, 1, 1)
  else
    love.graphics.setColor(0.2, 0.2, 0.2, 1) -- dark card back
  end

  love.graphics.rectangle("fill", self.position.x, self.position.y, self.size.x, self.size.y, 6, 6)

  if self.faceUp then
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(self.rank, self.position.x + 5, self.position.y + 5)
    local centerX = self.position.x + self.size.x / 2
    local centerY = self.position.y + self.size.y / 2
    local size = 7

    if self.suit == "♥" then
      self:drawHeart(centerX, centerY, size)
    elseif self.suit == "♦" then
      self:drawDiamond(centerX, centerY, size)
    elseif self.suit == "♣" then
      self:drawClub(centerX, centerY, size)
    elseif self.suit == "♠" then
      self:drawSpade(centerX, centerY, size)
    end
  end
end

function CardClass: checkForMouseOver(grabber)
  if self.state == CARD_STATE.GRABBED then
    return
  end    
  
  local mousePos = grabber.currentMousePos
  local isMouseOver = 
    mousePos.x > self.position.x and
    mousePos.x < self.position.x + self.size.x and
    mousePos.y > self.position.y and
    mousePos.y < self.position.y + self.size.y
    
    self.state = isMouseOver and CARD_STATE.MOUSE_OVER or CARD_STATE.IDLE
end

function CardClass:drawHeart(x, y, size)
  love.graphics.setColor(1, 0, 0, 1)
  love.graphics.circle("fill", x - size / 2, y, size / 2)
  love.graphics.circle("fill", x + size / 2, y, size / 2)
  love.graphics.polygon("fill", x - size, y, x + size, y, x, y + size * 1.2)
end

function CardClass:drawDiamond(x, y, size)
  love.graphics.setColor(1, 0, 0, 1)
  love.graphics.polygon("fill", 
    x, y - size,
    x + size, y,
    x, y + size,
    x - size, y
  )
end
function CardClass:drawClub(x, y, size)
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.circle("fill", x, y - size / 2, size / 2)
  love.graphics.circle("fill", x - size / 2, y + size / 3, size / 2)
  love.graphics.circle("fill", x + size / 2, y + size / 3, size / 2)
  love.graphics.rectangle("fill", x - size / 6, y + size / 2, size / 3, size)
end
function CardClass:drawSpade(x, y, size)
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.circle("fill", x - size / 2, y, size / 2)
  love.graphics.circle("fill", x + size / 2, y, size / 2)
  love.graphics.polygon("fill", x - size, y, x + size, y, x, y - size * 1.2)
  love.graphics.rectangle("fill", x - size / 6, y, size / 3, size)
end

function CardClass:isClicked(mx, my)
  return mx > self.position.x and mx < self.position.x + self.size.x and
         my > self.position.y and my < self.position.y + self.size.y
end
