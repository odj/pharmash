---
title: Enumerations in OUCH  
description: Basic chemical enumeration framework in Haskell.
author: Orion Jankowski
tags: OUCH, Haskell, chemistry, enumeration, canonicalization
---

<script src="../lib/RGraph/libraries/RGraph.common.core.js" ></script> 
<script src="/lib/RGraph/libraries/RGraph.common.context.js" ></script> 
<script src="/lib/RGraph/libraries/RGraph.common.annotate.js" ></script> 
<script src="/lib/RGraph/libraries/RGraph.common.tooltips.js" ></script> 
<script src="/lib/RGraph/libraries/RGraph.common.zoom.js" ></script> 
<script src="/lib/RGraph/libraries/RGraph.common.resizing.js" ></script> 
<script src="/lib/RGraph/libraries/RGraph.hbar.js" ></script>
<script> 
    /**
    * The onload function creates the graph
    */
    window.onload = function ()
    {
        var hbar1 = new RGraph.HBar('hbar1', [4347, 1858, 802, 355, 159, 75, 35, 18, 9, 5, 3, 2, 1, 1, 1]);
        var grad = hbar1.context.createLinearGradient(0,0,450,0);
        grad.addColorStop(0, 'white');
        grad.addColorStop(1, 'orange');
        hbar1.Set('chart.labels', ['15', '14', '13', '12', '11', '10', '9', '8', '7', '6', '5', '4', '3', '2', '1']);
        hbar1.Set('chart.title', 'Isomers in the Acyclic Alkane Series');
        hbar1.Set('chart.title.xaxis', 'Number of Isomers');
        hbar1.Set('chart.title.yaxis', 'Number of Carbons');
        hbar1.Set('chart.colors', [grad]);
        hbar1.Set('chart.strokestyle', 'orange');
        hbar1.Set('chart.background.barcolor1', 'white');
        hbar1.Set('chart.background.barcolor2', 'white');
        hbar1.Set('chart.background.grid.autofit', true);
        hbar1.Set('chart.vmargin', 2);
        hbar1.Set('chart.text.style', '#333');
        if (!RGraph.isIE8()) {
            hbar1.Set('chart.zoom.vdir', 'center');
            hbar1.Set('chart.contextmenu', [['Get PNG', RGraph.showPNG], ['Zoom in', RGraph.Zoom], ['Clear', function ()
              {RGraph.Clear(hbar1.canvas); hbar1.Draw();}]]);
            hbar1.Set('chart.annotatable', false);
        }
        hbar1.Set('chart.grouping', 'grouped');
        hbar1.Set('chart.gutter', 30);
        hbar1.Set('chart.labels.above', true);
        // var size = 30;
        hbar1.Set('chart.gutter', 30);
        hbar1.Draw();
    }
</script>
<script> 
    if (RGraph.isIE8()) {
        document.write('<div style="background-color: #fee; border: 2px dashed red; padding: 5px"><b>Important</b><br /><br /> Internet Explorer does not natively support the HTML5 canvas tag yet, so if you want to see the graphs, you can either:<ul><li>Install <a href="http://code.google.com/chrome/chromeframe/">Google Chrome Frame</a></li><li>Use ExCanvas. This is provided in the RGraph Archive.</li><li>Use another browser entirely. Your choices are Firefox 3.5+, Chrome 2+, Safari 4+ or Opera 10.5+. </li></ul></div>');
    }
</script>

##OUCH Structure Enumeration Strategies

In the first post about [OUCH](/posts/2010-08-02-ouch.html), I introduced the use of list comprehension to manipulate SMILES strings as a poor man's method of Markush enumeration.  This has now been extended more generally to manipulate the underlying data model directly, while maintaining the advantages of lazy evaluation.  

One of the less useful things this can be used for is to enumerate the acyclic saturated alkane series (ignoring stereochemistry).   In itself, this is not particularly interesting (nor efficient), but it does demonstrate the concept (and serve as an pathological test case for canonicalization).

The infix function `(>#>)` uses the list monad to enumerate structures according to a specified method, which can be just about anything (reactions, filters, patent provisios, etc.)  For alkane enumeration, the method upon which to enumerate is very simple: if you find a vacant position, add a carbon to it.  This can be concisely defined within [OUCH](/posts/2010-08-02-ouch.html) in the code below.

~~~~~~~{.haskell}
carbon = makeMoleculeFromAtom $ Element 6 0 Set.empty Set.empty

mth = Just $ AddMethod 
  { firstApply=Nothing
  , lastApply=makeUnique
  , selector=openValenceSelector
  , addList=[(Single, carbon)] 
  }

makeUnique = Just $ FilterMethod
  { firstApply=Nothing
  , lastApply=Nothing
  , molFilter=fingerprintFilterBuilder (\m -> writeCanonicalPath m) 
  }

alk :: Int -> [Molecule] 
alk i = List.foldr (\enum mols -> enum mols) [carbon] 
                 $ List.replicate (i-1) (>#>  mth)
main = do
  arg:_ <- getArgs
  let ns = [1..read arg::Int]
      lengths = List.map (List.length . alk) ns
  Prelude.putStrLn $ show $ List.zip ns lengths
~~~~~~~~

If what you're truly after is a list of all acyclic alkanes of length N, then this is probably not the method for you, but it does work.  At each iteration enumeration step, it builds not just the full list of possible alkanes, but **every conceivable graph representation** based on the previous list, which is spectacularly redundant.


But what is lost in efficiency is made up for as a diabolical test case for SMILES canonicalization.  For each unique isomer, every possible graph representation is produced in the pre-filtered list.  After filtering on canonical SMILES key, we'd better get the correct number of isomer.  Here's what we should find taken from [L. Bytautas and D. J. Klein](http://pubs.acs.org/doi/abs/10.1021/ci980095c):

***

<canvas id="hbar1" width="600" height="400" >[No canvas support]</canvas> 


***

And this is indeed what we get, although it's worth noting that this becomes quite slow very quickly, considering that in the case of moving from n=14 to n=15, we must generate canonical SMILES for approximately 26,000 isomers in order to identify the 4347 that are unique.  This wouldn't be so bad, except that because the structures are quite featureless, path comparisons are close to worst-case.

~~~~~~~{.haskell}
Main> :main 12
[(1,1),(2,1),(3,1),(4,2),(5,3),(6,5),(7,9),(8,18),(9,35),
(10,75),(11,159),(12,355)]
Main>
~~~~~~~~

Perhaps a more useful example: let's say you wanted all the single oxygen methylation products of heparin.  Easy, just define `mth` as follows: 


~~~~~~~{.haskell}

mth = Just $ AddMethod
  { firstApply=Nothing
  , lastApply=Nothing
  , selector=(openValenceSelector >&&> elementSelector "O")  
  , addList=[(Single, carbon)]
  }

~~~~~~~~  

Then `let heparin_derivatives = [heparin] >#> mth` and you have them all!

As a convenience, I plan to eventually build a method constructor based on SMIRKS (or something like it), but for now methods need to be constructed in code.

\[2010-09-22\]: *Converted isomers table from plain-vanilla HTML to [RGraph](http://www.rgraph.net/index.html).  Sweet!*

<br><br>

