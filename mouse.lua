require "card"

local mouse = {}

 function mouse.checkForMouseMoving(grabber)
  if grabber.currentMousePos == nil then
    return
  end
  
for _, card in ipairs(cardTable) do
    card: checkForMouseOver(grabber)
  end
  
 
  
end
 return mouse