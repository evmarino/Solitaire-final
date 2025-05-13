**Solitaire, but better by Evelyn Marino**

*Programming Patterns Used*

-- Constructor Pattern-- 
CardClass:new(x, y, suit, rank) builds each card with its own position, size, and state without repeating setup code. I did this because it simplifies creating the 52 card deck and any new cards during draws or redeals.

--Singleton Pattern--
The Snap module holds all layout data such as stack slots, foundation slots, snap radius, in one place.
This ensures drawing and drop-logic use the exact same coordinates, and makes it easy to adjust layout globally.

--Iterator Pattern--
Frequent for … in ipairs(tableauColumns[col]) do … end loops traverse piles of cards. Implemented because Lua’s built-in iteration makes it simple to draw, update, or test every card in a pile in a single construct.

*People Who Gave Feedback*
-- Andrea V. reviewed my code during discussion section and pointed out i still had leftover files (such as my cardDeck.lua and deck.lua files. I removed those redundant files and consolidated deck logic into startGame(). 


*Assets Used*
-- I didnt use any third party assets
-- Created in draw() function of my code

*PostMortem* 

What I did well

-- I broke the problem into clear pieces—handling clicks and drags in Grabber, laying out slots in Snap, and rendering cards in CardClass—so each file had a single responsibility. 

-- Starting with just moving one card, then building up tableau stacks, then adding the waste-pile logic let me catch bugs early and kept the code mostly stable.

What I’d do differently

-- next time i’d move the validation rules, foundational pile and tableau, into separate functions to reduce the giant release() method in grabber.lua and have more neatness. 