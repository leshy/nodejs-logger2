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
        logEntry = _.extend {}, { tags: tags, msg: msg }, data
        @event logEntry

Console = exports.Console = Backbone.Model.extend4000
    name: 'console'
    initialize: -> @startTime = new Date().getTime()
    log: (logEvent) ->
        console.log colors.green(new Date().getTime() - @startTime) + "\t" + colors.yellow(new Date()) + " " + colors.green(logEvent.tags.join(', ')) + " " + logEvent.msg        


Udp = exports.Udp = Backbone.Model.extend4000
    name: 'udp'
    initialize: (settings = { host: 'localhost', port: 6000 } ) ->
        @gun = new UdpGun settings.port, settings.host
    log: (logEvent) ->
        @gun.send new Buffer JSON.stringify _.extend {}, settings.extendPacket or {type: 'node' }, logEvent


#LogstashOutput = (logEvent,settings=settings.logstash) ->
#    if not gun = settings.logstash.gun
#        gun = settings.logstash.gun = new UdpGun settings.post, settings.host
#    gun.send new Buffer JSON.stringify _.extend {}, settings.extendPacket, logEvent.entry
        
    
#console = exports.console = (logEvent,settings=settings) ->



        

        
