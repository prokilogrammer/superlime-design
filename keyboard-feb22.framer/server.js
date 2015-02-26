var express = require('express');
var bodyParser = require('body-parser');

var app = express()

app.use(bodyParser.json()); // for parsing application/json
app.use(bodyParser.urlencoded({ extended: true })); // for parsing application/x-www-form-urlencoded

app.get('/report', function(req, res, next){

    console.log("------- METRIC --------");
    var metric = JSON.parse(req.query.val);
    console.log(JSON.stringify(metric, null, 2));

    res.sendStatus(200);
});

app.use(express.static('public'));


var server = app.listen(8000, function(){

    console.log("Server started at ", server.address().address, server.address().port)

});
