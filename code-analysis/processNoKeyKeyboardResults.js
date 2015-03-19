
var _ = require('lodash'),
    statistics = require('simple-statistics'),
    fs = require('fs'),
    gm = require('gm'),
    RandomColor = require('just.randomcolor');


// Mean position of all points
var mean = function(positions){
    return {
        x: Math.round(statistics.mean(_.pluck(positions,'x'))),
        y: Math.round(statistics.mean(_.pluck(positions,'y')))
    }
};

// Distance between two points
var distance = function(a, b){
    if (!a || !b) return 0;

    // Distance between two points
    var dist = Math.round(Math.sqrt(Math.pow(a.x - b.x, 2) + Math.pow(a.y - b.y,2)))
    return dist;
};

var removeOutliers = function(clickPositions){

    // Removes outliers from click positions.
    // Remove all points that are given tolerance pixels away from the centroid

    var tolerance = 150;

    var centroid = mean(clickPositions);
    return _.filter(clickPositions, function(pos){
        return distance(centroid, pos) < tolerance;
    })
};

var clean = function(raw){

    // Aggregate stats from all trials
    var aggregate = {};
    _.forEach(raw, function(rawStat){
        _.forEach(rawStat.canvasClickTrack, function(charpos){
            if (!_.has(aggregate, charpos.char)){ aggregate[charpos.char] = []}
            aggregate[charpos.char].push({x: charpos.x, y: charpos.y})
        })
    });


    var cleanedAggregate = [];
    _.forOwn(aggregate, function(positions, char){
        cleanedAggregate[char] = removeOutliers(positions);
        console.log("Removed " + (positions.length - cleanedAggregate[char].length) + " outliers for char " + char + " from " + positions.length + " original points")
    });

    return cleanedAggregate;
};

var plot = function(stats, prototypeImg){

    console.log("Creating stats image");

    var radius = 1;
    var img = gm(prototypeImg);

    var randomColors = new RandomColor({}, _.keys(stats).length);
    var colors = _.map(randomColors.toHex().colors, function(hex){ return "#"+hex.value});
    var index = -1;
    _.forOwn(stats, function(positions, char){

        index += 1;
        img = img.stroke(colors[index]);
        _.forEach(positions, function(pos){
            img.drawCircle(pos.x-radius, pos.y-radius, pos.x+radius, pos.y+radius)
        })
    });

    img.write("stats-"+prototypeImg, function(err){
        return err ? console.error(err) : console.log("Done writing stats image");
    })
};

var stats = function(raw, prototypeImg){

    var cleaned = clean(raw);

    // For each character, calculate some statistics:
    //  1. Avg, SD, min, max of distance of each point from centroid of the cluster

    _.forOwn(cleaned, function(positions, char){

        var centroid = mean(positions);
        var distFromCentroid = _.map(positions, function(pos){
            return distance(pos, centroid);
        });

        if (char == '\n') char = '\\n';
        if (char == ' ') char = '_space_';

        console.log("Char " + char + ": ")
        console.log("\tAvg: " + statistics.mean(distFromCentroid));
        console.log("\tSD: " + statistics.standard_deviation(distFromCentroid));
        console.log("\tMin: " + statistics.min(distFromCentroid));
        console.log("\tMax: " + statistics.max(distFromCentroid));

    });

    // Plot the points on the prototype
    if (prototypeImg) {
        plot(cleaned, prototypeImg);
    }

};




var prototypeImg = "prototype-screenshot-noKeyKeyboard.png"
var file = "../experimentresults/noKeyKeyboard/sanath-1.json";
var raw = JSON.parse(fs.readFileSync(file));

stats(raw, prototypeImg);
