---
title: Enumerations in OUCH  - Part 3
description: Trying to break canonicalizers for Ouch, Open Babel and JChem
author: Orion Jankowski
tags: OUCH, Haskell, chemistry, enumeration, canonicalization
---

<STYLE type="text/css">
   img {border: 2px solid orange; display: inline; margin: 2px 10px 2px 10px}
   p.caption {font-size: 14px; align: left; text-align: left; color: black;}
   table.example {font-size: 14px; display: block; text-align: center; color: black;}
 </STYLE>


##Pathological SMILES
It has been a long while since my last post here.  Since then, the SMILES writer implementation in [OUCH](/posts/2010-08-02-ouch.html) has been completely rewritten to be more consistent with idiomatic Haskell as well as far more flexible (but more on this in a future post).  Given this, it seemed like a good time to explore performance metrics, particularly for generating canonical SMILES.  OUCH does not use the Weiningers' method [^1] (at least not yet), which basically amounts to a clever method of memoization.  The reason for this is to keep the implementation as generalizable as possible within the constraints of the grammar (LL[1], I think) -- aggressive memoization makes this flexibility more difficult.  As such, it is not clear to me what the performance of SMILES canonicalization in OUCH would be expected to be -- indeed performance is not a simple thing to metricize given the diversity of chemical graphs.

So, I set out to generate structural series that would represent what I thought to be a worst-case scenario for canonicalization (at least for OUCH).  The first of these is the subject of this post: spirodendrimers.

##Spirodendrimers
It's easier to just show these than it is to describe them in words.  The first three structures for a series based on three membered rings is shown in the table below.  


<table  class="example">
  <tbody>
    <tr>
      <td>
        <u>Structure 3-1</u><br>
        <img src="/images/spiro3_1.png" />
      </td>
      <td>
        <u>Structure 3-2</u><br>
        <img src="/images/spiro3_2.png" />
      </td>
      <td>
        <u>Structure 3-3</u><br>
        <img src="/images/spiro3_3.png" />
      </td>
  </tbody>
<table>


The series is enumerated by starting with a ring of size *m* and adding new spiro-fused rings at all open valences for each subsequent generation.  Any given structure can therefore be described by two parameters: ring size (*m*) and generation (*n*).   The number of vertices is given by the equation below, which--happily or not--explodes very quickly.  (The equation is rendered using in-line [MathML](http://en.wikipedia.org/wiki/MathML).  On my machine, only Firefox seems to have rendered it correctly.  Chrome/Konquorer don't pick up the exponent.)


<math xmlns="http://www.w3.org/1998/Math/MathML">
 <semantics>
  <mrow>
   <mrow>
    <msub>
     <mi>F</mi>
     <mrow>
      <mi>m</mi>
      <mi>,</mi>
      <mi>n</mi>
     </mrow>
    </msub>
    <mo stretchy="false">=</mo>
    <mrow>
     <mi>m</mi>
     <mo stretchy="false">⋅</mo>
     <mrow>
      <munderover>
       <mo stretchy="false">∑</mo>
       <mrow>
        <mrow>
         <mi>i</mi>
         <mo stretchy="false">=</mo>
         <mn>1</mn>
        </mrow>
       </mrow>
       <mrow>
        <mi>n</mi>
       </mrow>
      </munderover>
      <msup>
       <mrow>
        <mo stretchy="false">(</mo>
        <mrow>
         <mrow>
          <mi>m</mi>
          <mo stretchy="false">−</mo>
          <mn>1</mn>
         </mrow>
        </mrow>
        <mo stretchy="false">)</mo>
       </mrow>
       <mrow>
        <mo stretchy="false">(</mo>
        <mrow>
         <mrow>
          <mi>i</mi>
          <mo stretchy="false">−</mo>
          <mn>1</mn>
         </mrow>
        </mrow>
        <mo stretchy="false">)</mo>
       </mrow>
      </msup>
     </mrow>
    </mrow>
   </mrow>
  </mrow>
 </semantics>
</math>


Using OUCH, the short program [here](/resources/spiro.hs) was used to generate the first eleven members of the [*m*=3 series](/resources/spiro.txt).  I was only able to go to [eleven](http://www.youtube.com/watch?v=EbVKWCpNFhY) before my computer caught on fire.  These are not canonicalized SMILES, but they are *valid* SMILES.  How far can your favorite canonicalizer go before it hits the wall?  Results to follow....

BTW, I haven't looked yet, but I'd be willing to bet that some machismo synthetic chemist out there has already made a few of these (or at least proposed it).  I'll add a reference if I find one (or have one sent to me).

Commit: [cecac19575f4f4a05edba12bdf8ae7655d76a69a](http://www.youtube.com/watch?v=EbVKWCpNFhY)



[^1]: Weininger D., Weininger A., Weininger J. L. (1989) SMILES. 2. Algorithm for generation of unique SMILES notation.  J. Chem. Inf. Comput. Sci. 29: 97-101. doi: 10.1021/ci00062a008
