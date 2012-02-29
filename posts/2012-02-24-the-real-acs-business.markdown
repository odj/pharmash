---
title: Node.js Open Babel Bindings
description: An example of Node.js bindings to Open Babel and a simple web demo.
author: Orion Jankowski
tags: node.js, OpenBabel
---

##Node.js Bindings for Open Babel
[Open Babel](http://openbabel.org/wiki/Main_Page)[^1] already has bindings from its
native C++ to other languages, provided by [SWIG](http://www.swig.org/).  One language platform 
which does not seem supported by SWIG yet is v8 JavaScript, on which [Node.js](http://nodejs.org/) is
based.  Since I just [moved](http://www.pharmash.com/posts/2011-10-12-deployment-changes.html)
pharmash over to Node.js, I thought this would be a good excuse to try writing bindings to OpenBabel.[^2].

##Arkleseizure
The *very* preliminary result of this effort is [arkleseizure](http://github.com/odj/arkleseizure)[^3],
a Node.js module that exposes just enough of the Open Babel API to provide convenient translation
of chemical formats.

Using Arkleseizure, it is very easy to define a route in Node.js (using the excellent [Express](http://expressjs.com/)
framework), that takes a POST request and throws back a translated representation:

~~~~~~~{.javascript }
var arkleseizure = require('arkleseizure');

app.post('/convert', function(req, res){
    a = new arkleseizure.OBConvert();
    a.SetInFormat(req.body.inputFormat);
    a.SetOutFormat(req.body.outputFormat);
    var output = a.Convert(req.body.inputValue); 
    res.send(output);
});
~~~~~~~

And you can see it in action here:

<script src="/lib/jquery/jquery-1.4.2.min_files/jquery.min.js" ></script>
<script src="/js/arkleseizure-demo.js" ></script>
<div class="vignette">
<table id="obabel" width="100%">
<tr>
  <td>
  Input Format:
  <select name="inputFormat" id="inputFormat"  value="smi">
    <option selected value="smi">SMILES format</option>
    <option value="mol">MDL MOL format</option>
    <option value="inchi">InChI format</option>
  </select>
  </td>
  <td>
  Output Format:
  <select name="outputFormat" id="outputFormat">
    <option value="smi">SMILES format</option>
    <option value="can">Canonical SMILES format</option>
    <option selected value="mol">MDL MOL format</option>
    <option value="inchi">InChI format</option>
  </select> 
  </td>
  <td>
  <button onclick="updateOutput()">Convert</button>
</tr>
</table>
<textarea name="inputValue" id="inputValue" style="background-color: #FFFFFF;" cols="80" rows="3" defaultValue="Enter input here" onclick="inputClicked()">
Enter input here</textarea>
<textarea name="ouputValue" id="outputValue" style="background-color: #F0F0F0;" cols="80" rows="25" disabled="true" >
Output will be displayed here
</textarea>
</div>


[^1]: Noel M. O'Boyle , Michael Banck , Craig A. James , Chris Morley , Tim Vandermeersch  and Geoffrey R. Hutchison.  Open Babel: An open chemical toolbox.  J. Cheminform. 2011 3(1):33.  
[^2]: The actual motives were probably the other way 'round.  When I finally get to writing Haskell 
bindings, I'll probably move the server over to [Snap](http://snapframework.com/).
[^3]: Arkleseizure commit: [00b38f21b60dd81acfa8e10eb344bad29a9a2b45](http://github.com/odj/arkleseizure)
