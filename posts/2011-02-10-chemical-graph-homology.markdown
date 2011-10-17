---
title: Chemical Graph Homology
description: Levenshtein distance for chemical graphs: n unimplemented concept.
author: Orion Jankowski
tags: OUCH, chemistry, graph
---

<STYLE type="text/css">
   img {border: 2px solid orange; display: inline; margin: 2px 10px 2px 10px}
   p.caption {font-size: 14px; align: left; text-align: left; color: black;}
   table.example {font-size: 14px; display: block; text-align: center; color: black;}
 </STYLE>





##Chemical Graph Homology

The biopolymer informatics folks are lucky.  They have (at first glance) an easier time comparing structures because they can be described as linear sequences--at least if we leave out carbohydrates.  At its most simplistic, they can compare structures by [Levenshtein Distances](http://en.wikipedia.org/wiki/Levenshtein_distance) between two sequence strings; very sophisticated variants on this theme are the foundation of their informatics systems. 

For small molecules informatics, we have no such sequence to compare, so instead we compare metrics that are derived from the molecular graph (fingerprints) to calculate a pairwise similarity.  In this respect, there is nothing absolute in the definition of similarity and therefore how it is to be calculated is entirely a judgment in matching it to the intended use.  For chemists interested in the pharmacology of molecules, it would be very useful to define similarity to have some correlation with pharmacological similarity at some level (although what pharmacologically similar means is also a matter of judgment).

There has been a recent attempt to convert graph elements into canonical linear sequences that can be compared in some meaningful pharmacologically sense[^1][^2].  This would allow chemists to bring to bear many of the powerful tools developed by the biopolymer community, but descriptors based on this method can be quite discontinuous as a consequence of the canonicalization method used.  As a result, two similar molecules could yield quite divergent linear descriptors.

An alternative method is to abstract the Levenshtein Distance concept for strings into the concept of graphs.  The allowable edit transformations would be graph transformations instead of string transformations.  For example, a complete set of graph transformations that will be able to convert any molecular structure into any other would be:

  - Add atom
  - Remove atom
  - Add bond
  - Remove bond

The distance between to chemical structures would be the minimum number of edit transformations required to convert one structure to another.  (There are some obvious similarities between this concept and methods for synthetic route planning--a subject on which I'm quite opinionated and the topic of some future post.)  Most likely, a different set of edit transformations would be more valuable for calculating chemical distances that have some pharmaceutical meaning.  For example:

  - Exchange aromatic ring
  - Expand ring
  - Contract ring
  - Exchange heteroatom
  - Insert concatenated atom
  - Remove concatenated atom

Such a edit set need not be complete (which is to say that two arbitrary structures might not have a sequence of edit transforms that can convert them), and could optionally be weighted (for example, to make swapping of equivalent functional groups a 'free' transformation).

In [Ouch](http://www.pharmash.com/tags/OUCH.html), the type signature for such a distance function would be:

~~~~~~~{.haskell }
distance :: Int 
         -> [(Int, Method)] 
         -> Molecule 
         -> Molecule 
         -> Either Int Int
~~~~~~~

Where the first argument is the maximum depth to search, and the second is a list of weighted [Method](https://github.com/odj/Ouch/blob/master/Ouch/Enumerate/Method.hs)s to use.  If no sequence of methods is found that can transform the two structures within the depth constraint, then `Left` is returned indicating the maximum depth searched.

The downside of such a similarity algorithm is that it could not possibly be made efficient.  Depending on how the edit transform set is defined, the maximum searchable depth could be very low (e.g. less than 10).  On the other hand, it could provide a new (maybe useful) view into clustering focused sets of compounds.

As an aside, The San Francisco Bay Area's first [Haskell Hackathon](http://wiki.hackerdojo.com/w/page/32992961/Haskell-Hackathon-2011) is this weekend.  Perhaps this functionality will be elevated from its vapor ware status.

<br><br><br>

[^1]: Hähnke, V., Hofmann, B., Grgat, T., Proschak, E., Steinhilber, D. and Schneider, G. (2009), PhAST: Pharmacophore alignment search tool. Journal of Computational Chemistry, 30: 761–771. doi: 10.1002/jcc.2109
[^2]: Hähnke, V., Rupp, M., Krier, M., Rippmann, F. and Schneider, G. (2010), Pharmacophore alignment search tool: Influence of canonical atom labeling on similarity searching. Journal of Computational Chemistry, 31: 2810–2826. doi: 10.1002/jcc.21574

