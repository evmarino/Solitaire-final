**Solitaire Beta by Evelyn Marino**

*Programming Patterns Used*

-- Constructor Pattern-- 
CardClass:new(x, y, suit, rank) builds each card with its own position, size, and state without repeating setup code.
I did this because it simplifies creating the 52 card deck and any new cards during draws or redeals.

--Singleton Pattern--
The Snap module holds all layout data such as stack slots, foundation slots, snap radius, in one place.
This ensures drawing and drop-logic use the exact same coordinates, and makes it easy to adjust layout globally.

--Command Pattern--
Encapsulated mouse actions as Grabber:grab() and Grabber:release() commands.
This cleanly separates “what happens on click” from “how cards move,” making the input logic easier to debug.

--Iterator Pattern--
Frequent for … in ipairs(tableauColumns[col]) do … end loops traverse piles of cards. Implemented because Lua’s built-in iteration makes it simple to draw, update, or test every card in a pile in a single construct.

*Assets Used*
-- I didnt use any third party assets
-- Created in draw() function of my code

*PostMortem* 

What I did well

-- I broke the problem into clear pieces—handling clicks and drags in Grabber, laying out slots in Snap, and rendering cards in CardClass—so each file had a single responsibility. 

-- Starting with just moving one card, then building up tableau stacks, then adding the waste-pile logic let me catch bugs early and kept the code mostly stable.

What I’d do differently

I see I left in helper bits I never used—like the getTopCard function and an empty CardClass:update() method. Next time I’d either fully implement those or remove them. I also piled all the pile-rules into Grabber:release(), which works but feels messy; extracting foundation and tableau logic into separate strategy modules would keep each rule easier to tweak and track bugs. Lastly  instead of manually interpolating card positions, I’d integrate a small tweening library for smoother snap back and draw pile animations, and it would save me from writing a lot of repetitive code, but i was still working on optimization.