---
title: SPARQL to Chart  
description: Plotting cross-domain data.
author: Orion Jankowski
tags: RDF, Javascript, AJAX
---

##Living with Internet "Security"

This post is a reply to Egon's challenge [here](http://chem-bla-ics.blogspot.com/2010/09/pulling-out-data-as-json-from-xhtmlrdfa.html?utm_source=feedburner&utm_medium=feed&utm_campaign=Feed:+blogspot/mpIP+(chem-bla-ics)) to see if someone could come up with a way of pulling out data from an XHTML+RDFa page and plotting it.

This looks like it should be a pretty simple AJAX hack, and it is, with one exception: the [sparql.org](http://sparql.org/) web resource is not cross-domain friendly.  Fortunately, this is a [common problem](http://snook.ca/archives/javascript/cross_domain_aj), and the example below uses the [cross domain proxy solution](http://ajaxpatterns.org/Cross-Domain_Proxy).  Doing things this way means that:

  1. you need some control over your own server to set up the proxy
  
  2. the owners of the resource you are accessing are not going to get pissed off
  
The proxy in this case is just a couple lines of PHP to redirect the form request to [sparql.org](http://sparql.org/) using cURL.  The actual plotting is done using [RGraph](http://www.rgraph.net/) with a little Javascript massaging to get the JSON data into a suitable form for plotting.  RGraph is not so fantastic at automatically setting up x-axis tick labels, but with a little extra effort, this could be made to look much nicer.  One could just as easily use the [Google Closure API](http://closure-library.googlecode.com/svn/docs/index.html) for rendering a graph.  It would be nice if Google Closure or RGraph could take a JSON-derived object directly and visualize it in some reasonably intelligent way, but perhaps that is asking too much.

Click the *Plot Results* button to try it out.  The query text is the same as Egon's example, but you should be able to modify it to plot something else if you like.

Enjoy!

----------

<script src="/lib/jquery/jquery-1.4.2.min_files/jquery.min.js" ></script>
<script src="/lib/RGraph/libraries/RGraph.common.core.js" ></script> 
<script src="/lib/RGraph/libraries/RGraph.common.context.js" ></script> 
<script src="/lib/RGraph/libraries/RGraph.common.annotate.js" ></script> 
<script src="/lib/RGraph/libraries/RGraph.common.zoom.js" ></script> 
<script src="/lib/RGraph/libraries/RGraph.common.tooltips.js" ></script> 
<script src="/lib/RGraph/libraries/RGraph.scatter.js" ></script>


<form action="sparql.org/sparql" method="get"> 
<p> 
    <textarea style="background-color: #F0F0F0;" name="query" cols="80" rows="10"></textarea> 
    <input type="hidden" name="default-graph-uri" value="" /> 
    <input type="hidden" name="output" value="json"/> <br/> 
    <input type="hidden" name="force-accept" value="text/plain"/>	  <br/> 
    <input type="button" value="Plot Results" onclick="getData()"/> 
</p> 
</form> 

<script type="text/javascript">
var oFormObject = document.forms[0];
oFormObject.elements["query"].value = "PREFIX cc: <http://github.com/egonw/cheminformatics.classics/1/#>\nSELECT *\nFROM\n<http://www.w3.org/2007/08/pyRdfa/extract?uri=http%3A%2F%2Fegonw.github.com%2Fcheminformatics.classics%2Fclassic1.html&format=pretty-xml&warnings=false&parser=lax&space-preserve=true>\n{\n    ?mol cc:w0 ?w ;\n         cc:p0 ?p .\n}\n"
</script>
<script type="text/javascript">
getData = function() {
  var qURL = $('form').attr("action") + "?" + $('form').serialize()
  RGraph.Clear(s1.canvas);    
  $.getJSON("/php/sparql.php", { query: qURL}, function(data)
    {plotData(data)});
  document.getElementById("scat1").style.display = "block";
  };
plotData = function(data) {
  var xLabel = data.head.vars[1];
  var yLabel = data.head.vars[2];
  console.log(xLabel);
  var points = data.results.bindings.reduce(function(acc, v, i, arr){
    if(acc){
      acc.push([v[xLabel].value, v[yLabel].value, 'orange']);
    } else {
      acc = [v[xLabel].value, v[yLabel].value, 'orange'];
    };
    return acc;
  }, []);
  var xMax = data.results.bindings.reduce(function(acc, v, i, arr){
    if(!acc){
      acc =eval(v[xLabel].value);
    } else {
      acc = Math.max(acc, eval(v[xLabel].value));
    };
    return acc;
  },0);
  var yMax = data.results.bindings.reduce(function(acc, v, i, arr){
    if(!acc){
      acc = eval(v[yLabel].value);
    } else {
      acc = Math.max(acc, eval(v[yLabel].value));
    };
    return acc;
  },0);
  s1.Set('chart.title.xaxis', xLabel);
  s1.Set('chart.title.yaxis', yLabel);
  s1.Set('chart.xmax', xMax); 
  s1.Set('chart.labels', [[0, "0"], [(xMax/2).toString(), xMax/2], [xMax.toString(), xMax]])    
  s1.data=[points];
  s1.Draw();
};
</script>
<script> 
        window.onload = function ()
        {
            data1 = [[10, 10, 'orange']];
            s1 = new RGraph.Scatter('s1', data1);
            s1.Set('chart.background.barcolor1', 'white');
            s1.Set('chart.background.barcolor2', 'white');
            s1.Set('chart.background.grid.autofit', true);
            s1.Set('chart.background.grid.autofit.numhlines', 10);
            s1.Set('chart.gutter', 80);
            s1.Set('chart.ylabels.count', 5);
            s1.Set('chart.xlabels.count', 5);
            s1.Set('chart.text.angle', 90);
            s1.Set('chart.tickmarks', 'circle');
            s1.Set('chart.ticksize', 15);
            s1.Set('chart.axis.color', 'orange')
          }
          </script>


<div id="scat1" style="display:none">
<canvas id="s1" width="600" height="350">[No canvas support]</canvas> 
<br><br>
</div>

<br><br>

