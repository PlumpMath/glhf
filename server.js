var express = require('express');
var path = require('path');
var fs = require('fs');
var _ = require('underscore');

var STATIC = path.join(__dirname, 'static');
var GADGET = process.cwd();
var TEMPLATE = path.join(STATIC, 'glhf.html');
var LOOKUPS = ['manifest.json', 'package.json', 'index.html'];

lookupManifest = function(gadgetPath, callback) {
  fs.readdir(gadgetPath, function(err, files) {
    var htmlFiles, lookup, _i, _len;
    for (var i = 0, len = LOOKUPS.length; i < len; i++) {
      lookup = LOOKUPS[i];
      if (_.contains(files, lookup)) {
        return callback({
          entry: lookup
        });
      }
    }

    htmlFiles = _.filter(files, function(file) {
      return /\.html$/.test(file);
    });

    if (htmlFiles.length === 1) {
      return callback({
        entry: htmlFiles[0]
      });
    }

    return callback({});
  });
};

serveIndex = function(req, res, next) {
  if (req.url !== '/') {
    return next();
  }

  lookupManifest(GADGET, function(manifest) {
    fs.readFile(TEMPLATE, 'utf-8', function(err, template) {
      if (err) {
        return res.send(500);
      }

      var content = _.template(template, manifest, { variable: 'manifest' });
      res.write(content);
      return res.end();
    });
  });
};

app = express()
  .use(serveIndex)
  .use(express["static"](STATIC))
  .use(express["static"](GADGET))
  .use(express.logger('dev'));

module.exports = app;
