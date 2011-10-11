---
title: Golfing with SMILES 
author: Orion Jankowski
tags: SMILES, Haskell, OUCH, Parsec
---

<STYLE type="text/css">
   img {border: 2px solid orange; display: inline; margin: 2px 10px 2px 10px}
   p.caption {font-size: 14px; align: left; text-align: left; color: black;}
   table.example {font-size: 14px; display: block; text-align: center; color: black;}
</STYLE>


##Parsing Doesn't Have to be Ugly

If any of you have looked at the SMILES parser module in [Ouch](/posts/2010-08-02-ouch.html), what you will find there is an awesome disaster of regex (subsequently referred to as the *Regex Disaster*).  It's been very difficult to maintain and almost impossible to extend.  I'm generally reluctant to touch it at all because I almost always break it in some subtle and insidious way.  I suspect it is also perfectly bewildering to anyone other than its author.  _In other words, it's exactly what code should not be._

So, before attempting to write a SMIRKS parser to construct [enumeration methods](/posts/2010-09-21-enumerations-in-ouch.html), I thought it might be wise to bring some more powerful weapons to the fight.  One of the most popular packages on [Hackage](http://hackage.haskell.org/packages/hackage.html) is a parsing library called [Parsec](http://hackage.haskell.org/package/parsec).  To try it out, I used Parsec to re-write the SMILES parser in Ouch.  

Parsec was terrifyingly effective at this task.  

##Executable Formal Grammar

At its best, coding in Haskell is like writing a specification, which happens to also be a program.  Using Parsec is a great example of this applied to formal grammars.  Even readers without a background in Haskell will probably see an immediate similarity between the [Open Smiles formal grammar](http://www.opensmiles.org/spec/open-smiles-2-grammar.html) and the code sample below for parsing the contents of a SMILES bracket string.

~~~~~~~{.haskell}
pBracket = bracket $ do isotope    <- pIsotope
                        atomSymbol <- pAtomSymbol
                        chiral     <- optionMaybe pStereo
                        explicitH  <- optionMaybe pHydrogen
                        atomCharge <- optionMaybe pCharge
                        atomClass  <- optionMaybe pClass
                        return $ (fromSymbol isotope atomSymbol) 
                                 >@> chiral 
                                 >@> explicitH 
                                 >@> atomCharge 
                                 >@> atomClass 
                                 >@> aromatic atomSymbol                        
~~~~~~~~~

Variables that start with `p` define a parser that consumes a string and uses the result to construct a piece of data, which is extracted by `<-` into a new variable.  The initial `bracket $` just before the do block indicates that everything that follows should be inside square brackets.  The operator `>@>` gives the newly minted atom the extracted property (if found), and `return` wraps the answer back up into the parser.

Compare this to:

[`bracket_atom ::= '[' isotope? symbol chiral? hcount? charge? class? ']'`](http://www.opensmiles.org/spec/open-smiles-2-grammar.html)

Parsers are then combined to create new parsers.  The top-level SMILES parser is shown below, which is defined recursively in terms of itself and a handful of other parsers.  `pBracket` is used to define `pAtom`, which is used to define `pSmiles`.

~~~~~~~{.haskell}
pSmiles = (emptyMolecule, Single) <$ char ')' <|>
          (emptyMolecule, Single) <$ eof      <|> 
            do bond      <- pBond
               geometry  <- optionMaybe pGeometry
               atom      <- pAtom
               subsmiles <- many (char '(' *> pSmiles)
               atoms     <- pSmiles
               let branched = List.foldr addSub atom subsmiles
               return (addSub atoms branched, bond)                                      
~~~~~~~

Parsec's golf score here was less than _75 lines_, as compared with the functionally equivalent Regex Disaster at around _300 lines_ (both support a fairly complete syntax).  Usually, as golf scores improve, readability severely declines.  The opposite was true here.

Even better, the Parsec code rips through the test suite slightly more than two times faster than the Regex Disaster.  I'm sold!  




