---
title: And Now For Something Completely Different
description: Yet Another Haskell Asteroids Clone
author: Orion Jankowski
tags: warp, Haskell, web-sockets
---

##YAHAC (Yet Another Haskell Asteroids Clone)
[Hackage](http://hackage.haskell.org) does not need another Asteroids clone.
There are already quite a few out there (although most won't compile with GHC 7.x
without a little massaging first).  Despite this, I've gone and written
another one for much the same reasons all the others exist: to explore applying
Haskell to a real-time stateful problem and have some fun doing it.  YAHAC has
a secondary goal: to render to the browser in real-time using web sockets.  In
principle, this will allow the game to function a bit like a chat-room.  Point
your browser at the server address and you are immediately thrown into a
cooperative (or competative) Asteroids game with any other players who are also
connected.   All the physics is performed server side, and rendering is entirely
performed by the browser.  More on this in future posts (as it is yet to be
implemented).  For now, some observations on the game implementation
with a local GTK/Cairo front-end.


###Disclaimer
Looking back so far there are a few things I'm sure other Haskellers will be critical of:

(1) The game state should live in its own monad (something to add soon)

(2) The game updates are FRP-ish, but make no particular attempt to follow a
well defined paradigm

(3) The game updates really ought to be pure (lives in the IO monad at the moment,
but there's a good reason for this, really)

Supportive criticism is always welcome, even if broadly categorized by 
one of the three points above.

###Observations So Far
While Haskell's type system brought its usual advantages (correctness, 
ease of refactoring), I can't help but feel that
the functional paradigm is mismatched to the problem of writing even a very simple game
like Asteroids.  Much of this exercise felt like reproducing an 
"[OOP](http://wcook.blogspot.com/2012/07/proposal-for-simplified-modern.html)-like" environment
inside a function framework.  For example, this aliasing of record syntax seemed 
particularly ugly, all in an attempt to co-localize the behavior of a game object with its state.


~~~~~~~~~{.haskell}
type ObjectUpdateIO = 
    Int        -- ^ The time in ms since the last update
 -> Basic      -- ^ The current object node
 -> Basic      -- ^ The root game node
 -> IO(Basic)  -- ^ Returns new root game node

data Basic = Basic   -- ^ The game object tree
    {
      -- many other fields ...
    , children          :: !(M.Map UUID Basic)
    , uuid              :: UUID  -- ^ The current object's UUID.
    , updatePositionFun :: ObjectUpdateIO  -- ^ Updates the position
    }

-- Access update position from record and self apply (this is ugly)
updatePosition diff self = updatePositionFun self diff self
~~~~~~~~~

I also needed a way to tightly couple the behavior of one *game object*
with another without resorting to some sort of IORef disaster.   This was accomplished by
assigning each *game object* a uuid, from which it could be accessed and modified by any
other object that was made aware of its existence.  But there is a price to pay: (1) 
the generation of UUIDs is (rightly) an IO action, which contaminates the purity of the game
state update and (2) searching around for the UUID you want inside the entire game state
is pretty slow compared to just holding a raw pointer.

In any case, the end result is quite satisfying and a good starting point for the 
next web-socket phase.  Unlike the classic Asteroids, YAHAC is a full multi-bodied gravity simulation,
which can be pretty hypnotizing to watch and very difficult to play.  

Check it out at [https://github.com/odj/Yahac.git](https://github.com/odj/Yahac.git)

[YAHAC Screenshot 1](../images/astroids1.png)

[YAHAC Screenshot 2](../images/astroids2.png)






