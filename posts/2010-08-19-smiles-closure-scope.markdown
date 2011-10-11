---
title: SMILES Connection Label Scope 
author: Orion Jankowski
tags: SMILES, chemistry
---

<STYLE type="text/css">
   img {border: 2px solid orange; display: inline; margin: 2px 10px 2px 10px}
   p.caption {font-size: 14px; align: left; text-align: left; color: black;}
   table.example {font-size: 14px; display: block; text-align: center; color: black;}
 </STYLE>


##Connection Label Scope in SMILES Substructures

While working on [Ouch](/posts/2010-08-02-ouch.html) I noticed a subtlety of [SMILES semantics](http://www.opensmiles.org/) that I wish was a little different (certainly not the only one).  It has to do with how connection markers are paired up when building a molecular graph representation of a SMILES string.  The SMILES connection label is set by the number that immediately follows an atom symbol.  When the next matching label is encountered later in the SMILES string, a bond (single or otherwise specified) is made between the two labeled atoms.  Paired atoms labels are identified in the order of their appearance in the overall SMILES string.

This behavior, however simple, is slightly inconvenient when it comes to both the implementation of a parser and the flexibility of SMILES as a format.  A preferred semantics would be to preferentially pair labeled atoms within a SMILES substring, and only afterwards, pair connects outside the substring.  More in this in a moment.

The best way of illustrating this is by a simple example.  In the figures below, the SMILES string `C1C(C1CC1)CC1` results in *Structure A* while the string `C1C(C2CC2)CC1` results in *Structure B*.  If, however, SMILES substrings (i.e. the part inside the parentheses) defines its own connection label scope, then both strings would results in *Structure B*. 

<table  class="example">
  <tbody>
    <tr>
      <td>
        <u>Structure A</u><br>
        <img src="/images/2010-08-19-smiles-example1.png" />
      </td>
      <td>
        <u>Structure B</u><br>
        <img src="/images/2010-08-19-smiles-example2.png" />
      </td>
    <tr>
      <td>SMILES: "C1C(C1CC1)CC1"</td>
      <td>SMILES: "C1C(C2CC2)CC1"</td>
    </tr>
  </tbody>
<table>

Why does this matter?  Because doing so would allow the SMILES sub-string to be substituted with just about anything without changing the overall interpretation of the rest of the string.  This gets back to the concept of the Poor Man's Markush described [here](/posts/2010-08-02-ouch.html).  By having a label scope preference within a substring, it allows SMILES to be a versatile vehicle for structure enumeration simply by manipulating strings.  It's also easier to implement: because a SMILES substring can be treated *exactly* like an ordinary SMILES string, a simple recursive algorithm could be defined to traverse any degree of substring depth.  And because any remaining unpaired labels can be used to mark connections to atoms outside the substring, you don't lose any functionality either.

SMILES are so well entrenched in the fabric of cheminformatics that changes like this can probably never happen.  And this change would not be without significant consequences either: out of the 1382 compounds in the [Drugbank ATM](/exhibits/approved_drugs.html), 21 would result in incorrect structures if SMILES were parsed with *substring label scope priority* as described here.  


 
