// Script to crunch the typing metrics and provide insights

var _ = require('lodash'),
    statistics = require('simple-statistics'),
    fs = require('fs');


// A result file has a JSON array of metrics from various test runs.
// Calculate following stats after aggregating:
// Mean and SD for:
//  1. Num of backspaces
//  2. Total duration
//  3. Time to type each character (sort chars and print result for easy comparison)

var getMeanSD = function(values){

    return {mean: statistics.mean(values), sd: statistics.standard_deviation(values)}
};

var joinMetrics = function(reportFile){

    var metrics = JSON.parse(fs.readFileSync(reportFile));
    var result = {};
    result['numBackspaces'] = _.pluck(metrics, 'numBackspaces');
    result['totalDuration'] = _.pluck(metrics, 'totalDuration');

    var charstats = {};
    _.forEach(metrics, function(metric){
        _.forOwn(metric.charstats, function(val, char){
            if (!_.has(charstats, char)) { charstats[char] = []}
            charstats[char].push(val.timeToType/val.count);
        })
    });

    return _.merge(result, charstats);
};

var getStats = function(metrics){

    var stats = {};

    _.forOwn(metrics, function(val, key){
        stats[key] = getMeanSD(val);
    });

    return stats;
};

var randomize = function(metrics1, metrics2){

    // Let's shuffle results for each metric between two runs and see if they still make sense

    _.forEach(_.keys(metrics1), function(key){

        var all = _.flatten([metrics1[key], metrics2[key]]);
        var shuffledResults = _.chunk(_.shuffle(all), Math.round(all.length/2));
        metrics1[key] =  shuffledResults[0];
        metrics2[key] =  shuffledResults[1];
    })

};


var fileBefore = '../experimentresults/dynamicButtonSizing/0-nosizing.json';
var fileAfter = '../experimentresults/dynamicButtonSizing/0-sizing.json';

var metricsBefore = joinMetrics(fileBefore);
var metricsAfter = joinMetrics(fileAfter);

randomize(metricsBefore, metricsAfter);

var statsBefore = getStats(metricsBefore);
var statsAfter = getStats(metricsAfter);

console.log(JSON.stringify(statsBefore, null, 2));
console.log(JSON.stringify(statsAfter, null, 2));

