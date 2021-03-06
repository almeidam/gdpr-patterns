express   = require 'express'
http      = require('http')
https     = require('https')
url       = require('url')

class Hugo_Proxy
  constructor: (options)->
    @.options       = options || {}
    @.hugo_Server   = 'localhost'
    @.port          = 1313
    @.app           = @.options.app
    @.router        = express.Router()

  add_Routes: ()=>
    @.handler_404()
    @.handler_errors()
    @.handler_star()
    @

  handler_404: ()->
    @.app.get? '/404',  (req, res)=>
      res.send "404 on <a href='#{req.query.url}'>#{req.query.url}"

  handler_star:()->
    @.app.get? '/*',  (req, res)=>
      options         = url.parse(req.url);
      options.host    = @.hugo_Server
      options.port    = @.port
      options.headers = req.headers;
      options.method  = req.method;
      connector = http.request options, (serverRes)->
        if serverRes.statusCode is 404
          res.redirect "/404?url=#{req.url}"
        else
          res.set 'content-type', serverRes.headers['content-type']
          serverRes.pipe(res, {end:true})
      req.pipe(connector, {end:true});
    @

  handler_errors: ()=>
    @.app.use '/throw-error',  (req, res)=>
      throw new Error("an error for you")

    @.app.use (err, req, res, next)->
      res.status(500).json(err.stack)


module.exports = Hugo_Proxy