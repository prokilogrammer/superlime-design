var express = require('express');
var fs = require('fs');
var bodyParser = require('body-parser');

var app = express()

app.use(bodyParser.json({limit: '50mb'})); // for parsing application/json
app.use(bodyParser.urlencoded({ extended: true, limit: '50mb' })); // for parsing application/x-www-form-urlencoded

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

app.post('/predictions', function(req, res, next){

    console.log("----- PREDICTIONS -----");
    fs.writeFile('predictions-sanath.json', JSON.stringify(req.body), function(err){
        res.sendStatus(err ? 500 : 200);
    })
});

app.post('/log', function(req,res,next){
    console.log(req.body);
    res.sendStatus(200);
});

app.use(express.static('public'));


var server = app.listen(8000, function(){

    console.log("Server started at ", server.address().address, server.address().port)

});
