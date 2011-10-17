---
title: Enumerations in OUCH  - Part 2 
description: Enumerating a molecular formula.
author: Orion Jankowski
tags: OUCH, Haskell, chemistry, enumeration 
---
##Enumerations of a Molecular Formula

Not long ago, [Noel](http://baoilleach.blogspot.com/) casually asked if anyone 
knew of an open-source application that would take a molecular formula and
give you all possible (valid) chemical structures.  I'm not sure if he found 
what he was looking for, nor what he would do with it if he did, but I thought
it would be a fun problem to apply [OUCH](/posts/2010-08-02-ouch.html) to.

Actually doing this turns out to be reasonably simple, with only about 50 lines
of code.  The implementation follows a Map-Reduce pattern (unsurprisingly), the
top level of which is shown below.  This makes it particularly easy to
parallelize to run on multiple cores, but also means it is in need of
[memoization](http://en.wikipedia.org/wiki/Memoization), in some cases
desperately so.

~~~~~~~{.haskell }
expand :: Formula -> [Molecule]
expand f = (List.concat mols) >#> makeUnique 
    where mols = List.map (\a -> compose a addMols) $ decompose f
~~~~~~~

At the moment, this is limited to *saturated, acyclic* structure enumeration.
This is not because rings or unsaturation are any more difficult to enumerate
using this framework, but because the canonicallizer does not yet deal with
them properly.  Chiral forms (not included here either) would need to be
enumerated *after* the structure graphs are generated, because it is impossible
to tell what will be a chiral center until all atoms are added.

The table below is an example of what one can do with this, which is still a
far cry from what I would described as *useful*.  But it is amusing.[^1]

<br>
<table class="post" style="empty-cells : hide; border-collapse: collapse;"> 
<col span="5" style="width: 5em" /> 
  <tr>
    <th></th>
    <th>X = Si</th>
    <th>X = N</th>
    <th>X = O</th>
    <th>X = Cl</th>
   </tr>
  <tr>
    <td>C~10~X~0~</td>
    <td>[75](/resources/enumerations/C10.out)</td>
    <td>[75](/resources/enumerations/C10.out)</td>
    <td>[75](/resources/enumerations/C10.out)</td>
    <td>[75](/resources/enumerations/C10.out)</td>
  </tr>
  <tr>
    <td>C~9~X~1~</td>
    <td>[549](/resources/enumerations/C9Si1.out)</td>
    <td>[507](/resources/enumerations/C9N1.out)</td>
    <td>[405](/resources/enumerations/C9O1.out)</td>
    <td>[211](/resources/enumerations/C9Cl1.out)</td>
  </tr>
  <tr>
    <td>C~8~X~2~</td>
    <td>[2119](/resources/enumerations/C8Si2.out)</td>
    <td>[1856](/resources/enumerations/C8N2.out)</td>
    <td>[1225](/resources/enumerations/C8O2.out)</td>
    <td>[332](/resources/enumerations/C8Cl2.out)</td>
  </tr>
  <tr>
    <td>C~7~X~3~</td>
    <td>[5048](/resources/enumerations/C7Si3.out)</td>
    <td>[4238](/resources/enumerations/C7N3.out)</td>
    <td>[2275](/resources/enumerations/C7O3.out)</td>
    <td>[312](/resources/enumerations/C7Cl3.out)</td>
  </tr>
  <tr>
    <td>C~6~X~4~</td>
    <td>[8345](/resources/enumerations/C6Si4.out)</td>
    <td>[6742](/resources/enumerations/C6N4.out)</td>
    <td>[2922](/resources/enumerations/C6O4.out)</td>
    <td>[198](/resources/enumerations/C6Cl4.out)</td>
  </tr>
  <tr>
    <td>C~5~X~5~</td>
    <td>[9782](/resources/enumerations/C5Si5.out)</td>
    <td>[7578](/resources/enumerations/C5N5.out)</td>
    <td>[2570](/resources/enumerations/C5O5.out)</td>
    <td>[78](/resources/enumerations/C5Cl5.out)</td>
  </tr>
  <tr>
    <td>C~4~X~6~</td>
    <td>[8345](/resources/enumerations/C4Si6.out)</td>
    <td>[6153](/resources/enumerations/C4N6.out)</td>
    <td>[1579](/resources/enumerations/C4O6.out)</td>
    <td>[20](/resources/enumerations/C4Cl6.out)</td>
  </tr>
  <tr>
    <td>C~3~X~7~</td>
    <td>[5048](/resources/enumerations/C3Si7.out)</td>
    <td>[3483](/resources/enumerations/C3N7.out)</td>
    <td>[625](/resources/enumerations/C3O7.out)</td>
    <td>[2](/resources/enumerations/C3Cl7.out)</td>
  </tr>
  <tr>
    <td>C~2~X~8~</td>
    <td>[2119](/resources/enumerations/C2Si8.out)</td>
    <td>[1341](/resources/enumerations/C2N8.out)</td>
    <td>[155](/resources/enumerations/C2O8.out)</td>
    <td>[0](/resources/enumerations/C2Cl8.out)</td>
  </tr>
  <tr>
    <td>C~1~9~0~</td>
    <td>[549](/resources/enumerations/C1Si9.out)</td>
    <td>[306](/resources/enumerations/C1N9.out)</td>
    <td>[18](/resources/enumerations/C1O9.out)</td>
    <td>[0](/resources/enumerations/C1Cl9.out)</td>
  </tr>
  <tr>
    <td>C~0~X~10~</td>
    <td>[75](/resources/enumerations/Si10.out)</td>
    <td>[37](/resources/enumerations/N10.out)</td>
    <td>[1](/resources/enumerations/O10.out)</td>
    <td>[0](/resources/enumerations/Cl10.out)</td>
  </tr>
</table>
<br>

If you want to generate massive lists of compounds of your own, download and
build [thunk](/resources/thunk.hs), a command line utility that parses a
molecular formula and spits out a list of unique structures (after some time)
that satisfy it.  You will need to have [OUCH](/posts/2010-08-02-ouch.html)
installed in your Haskell packages. 
 
Happy Enumerating!!!

<br>

\[2011-01-17\]: *Updated the table contents to reflect a correction to the error pointed out by Andrew in
the Disqus commments below.  More details on this to be found in an upcoming post.
The original table contents can be found [here](/resources/enumerations/old_enumerations_2010-12-19/old_enumerations.html).  New results from [0be42eeffb6eebbaf5e701acbe75222bd3fc3fdc](https://github.com/odj/Ouch/commit/0be42eeffb6eebbaf5e701acbe75222bd3fc3fdc).  For my own sanity, I plan to get in the habit of tagging code-related posts with a commit.*

<br><br><br>


[^1]: I have no way to veryify that the values in this table are actually correct.  If you
know a way to veryify them by graph theory or some other software package, I'd
love to know.


