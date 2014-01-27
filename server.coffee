express = require('express')
path = require('path')
fs = require('fs')
_ = require('underscore')

STATIC = path.join(__dirname, 'static')
GADGET = process.cwd();
TEMPLATE = path.join STATIC, 'glhf.html'

# Lookup sequence:
# - manifest.json
# - package.json
# - index.html
# - <any>.html (only if there is only one html file in root)
LOOKUPS = ['manifest.json', 'package.json', 'index.html']
# TODO: lookups are not supported yet in "static" directory

lookupManifest = (gadgetPath, callback = ->) ->
  fs.readdir gadgetPath, (err, files) ->

    # Return first matched path in lookups
    for lookup in LOOKUPS
      if _.contains(files, lookup)
        return callback { entry: lookup }

    # No manifest found yet. Maybe there is only one html?
    htmlFiles = _.filter files, (file) -> /\.html$/.test file
    if htmlFiles.length == 1
      return callback { entry: htmlFiles[0] }

    return callback {}

serveIndex = (req, res, next) ->
  return next() unless req.url == '/'

  lookupManifest GADGET, (manifest) ->
    fs.readFile TEMPLATE, 'utf-8', (err, template) ->
      return res.send(500) if err

      content = _.template(template, manifest, { variable: 'manifest' })

      res.write content
      res.end()

sendIndex = (req, res, content) ->
  res.write(content)
  res.end()

app = express()
  .use(serveIndex)
  .use(express.static(STATIC))
  .use(express.static(GADGET))
  .use(express.logger('dev'))

module.exports = app
