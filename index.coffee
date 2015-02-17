_ = require 'underscore'
Backbone = require 'backbone4000'
helpers = require 'helpers'
subscriptionMan = require('subscriptionman2')
validator = require('validator2-extras'); v = validator.v
colors = require 'colors'
UdpGun = require 'udp-client'
os = require 'os'
fs = require 'fs'

settings =    
    logstash:
        host: 'localhost'
        port: "6000"
        extendPacket:
            type: 'log',
            host: os.hostname()
        
#if fs.existsSync('./settings.js') then _.extend settings, require('./settings').settings

#gun = new UdpGun settings.port, settings.host


Logger = exports.Logger = subscriptionMan.basic.extend4000
    initialize: ->
        @outputs = new Backbone.Collection()
        @subscribe true, (event) =>
            @outputs.each (output) -> output.log event
    
    log: (msg, data = {}, tags...) -> 
        logEntry = _.extend {}, { tags: tags, message: msg }, data
        @event logEntry

Console = exports.Console = Backbone.Model.extend4000
    name: 'console'
    initialize: -> @startTime = process.hrtime()[0]
    parseTags: (tags) ->
        _.map tags, (tag) ->
            if tag is 'fail' or tag is 'error' then return colors.red tag
            if tag is 'pass' or tag is 'ok' then return colors.green tag                
            return colors.yellow tag
    log: (logEvent) ->
        hrtime = process.hrtime()
        tags = @parseTags logEvent.tags
        console.log colors.grey(new Date()) + "\t" + colors.green("#{hrtime[0]  - @startTime}.#{hrtime[1]}") + "\t " + tags.join(', ') + "\t⋅\t" + logEvent.message        


Udp = exports.Udp = Backbone.Model.extend4000
    name: 'udp'
    initialize: (@settings = { host: 'localhost', port: 6000 } ) ->
        @gun = new UdpGun @settings.port, @settings.host
        @hostname = os.hostname()
    log: (logEvent) ->
        @gun.send new Buffer JSON.stringify _.extend { type: 'nodelogger', host: @hostname }, @settings.extendPacket or {}, logEvent




        

        
