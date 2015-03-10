var express = require('express');
var fs = require('fs');
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

app.get('/nextcharprob', function(req, res, next){

    fs.readFile('../code-analysis/bigrams.json', function(err, data){
        if (err) {
            console.error(err);
            return res.sendStatus(500);
        }

        res.send(200, JSON.parse(data));
    });

});

app.use(express.static('public'));


var server = app.listen(8000, function(){

    console.log("Server started at ", server.address().address, server.address().port)

});
