var fs = require('fs'),
    shell = require('shelljs'),
    async = require('async'),
    _ = require('lodash');


var basedir = "./code";
var ext = "py";
var extRegex = new RegExp("\\." + ext + "$");

// Remove all forms of comments from the code.
var cleanupRegex = [/"""[^"]+"""/g, /#.*/g];

/*
  Example:
  {
    'a': {
        'b': {freq: 10},
        'c': {freq:20},
        'total': 30
    }
  }
 */
var bigrams = {};

// 1. Load existing bigram map
// 2. Load the list of analyzed files
// 3. Make list of N new files
// 4. Read each file, filter out comments and string literals
// 5. Count and update bigram map.
// 6. Write map in memory to file


var updateBigram = function(contents){
    if (contents.length == 0 || contents.length == 1) return;

    for(var i=0; i<(contents.length-1); i++){

        var thischar = contents[i];
        var nextchar = contents[i+1];

        if (!_.has(bigrams, thischar)) { bigrams[thischar] = {total: 0}}
        if (!_.has(bigrams[thischar], nextchar)) { bigrams[thischar][nextchar] = {freq: 0}}

        bigrams[thischar]['total'] += 1;
        bigrams[thischar][nextchar]['freq'] += 1;
    }
};


async.waterfall([

    function(callback){
        var allFiles = shell.find('.').filter(function(file) { return file.match(extRegex)})
        var analyzedFiles = JSON.parse(fs.readFileSync("analyzedFiles.json"));
        var toBeAnalyzed = _.difference(allFiles, analyzedFiles);
        console.log(toBeAnalyzed.length + " files yet to be analyzed");
//        toBeAnalyzed = toBeAnalyzed.slice(0, 2);

        bigrams = JSON.parse(fs.readFileSync("bigrams.json"));

        callback(null, toBeAnalyzed, analyzedFiles);
    },

    function(toBeAnalyzed, analyzedFiles, callback){

        async.map(toBeAnalyzed, function(file, cb){
            console.log("Analyzing " + file);
            fs.readFile(file, {encoding: "UTF-8"}, cb);
        },
        function(err, fileContents){
            callback(err, fileContents, toBeAnalyzed, analyzedFiles)
        })
    },

    function(fileContents, toBeAnalyzed, analyzedFiles, callback){

        async.each(fileContents, function(contents, cb){

            // Cleanup
            contents = _.reduce(cleanupRegex, function(result, regex){
                return result.replace(regex, '');
            }, contents);

            updateBigram(contents);
            cb(null);
        },
        function(err){
            callback(err, toBeAnalyzed, analyzedFiles);
        });
    },

    function(toBeAnalyzed, analyzedFiles, callback){

        fs.writeFile('bigrams.json', JSON.stringify(bigrams, null, 2), function(err){
            if (err) return callback(err);

            fs.writeFile('analyzedFiles.json', JSON.stringify(_.union(toBeAnalyzed, analyzedFiles), null, 2), callback);
        });
    }
])


