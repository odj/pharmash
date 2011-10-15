
/**
 * Module dependencies.
 */

var express = require('express');
var arkleseizure = require('arkleseizure');

var app = module.exports = express.createServer();

// Configuration

app.configure(function(){
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express.static(__dirname + '/_site'));
});


app.post('/convert', function(req, res){
    a = new arkleseizure.OBConvert();
    a.SetInFormat(req.body.inputFormat);
    a.SetOutFormat(req.body.outputFormat);
    var output = a.Convert(req.body.inputValue); 
    res.send(output);
});


app.configure('development', function(){
  app.use(express.logger({ format: 'dev'}));
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true })); 
});

app.configure('production', function(){
  app.use(express.logger({ format: 'default'}));
  app.use(express.errorHandler()); 
});

app.listen(80);
console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
