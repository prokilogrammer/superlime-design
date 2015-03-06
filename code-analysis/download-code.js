var _ = require('lodash'),
    async = require('async'),
    shell = require('shelljs');

var repos = [
   "https://github.com/jakubroztocil/httpie",
   "https://github.com/reddit/reddit",
   "https://github.com/scipy/scipy",
   "https://github.com/numpy/numpy",
   "https://github.com/ipython/ipython",
   "https://github.com/django/django",
    "https://github.com/python/cpython",
    "https://github.com/python/raspberryio"
];


async.each(repos, function(repoPath, callback){

    var repoName = repoPath.substr(repoPath.lastIndexOf('/')+1);
    var zipPath = "/tmp/" + repoName + ".zip";
    var codePath = "./code/" + repoName + "-master";
    var downloadPath = repoPath + "/archive/master.zip";

    if(shell.test('-d', codePath)){
        console.log(repoName + " already exists. skipping");
        return callback(null);
    }

    console.log("Downloading ", repoName);

    shell.exec("wget -q " + downloadPath + " -O " + zipPath, function(err){
        if (err) return callback(err);

        console.log("UNzipping " + zipPath);
        shell.exec("unzip -q " + zipPath + " -d ./code", function(err){
            callback(err);
        })
    });
});
