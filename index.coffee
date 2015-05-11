_ = require 'underscore'
Backbone = require 'backbone4000'
h = require 'helpers'
subscriptionMan = require('subscriptionman2')
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

Logger = exports.Logger = subscriptionMan.basic.extend4000
    matchAll: true

    initialize: (settings = {}) ->
        @settings = _.extend {}, settings

        @context = @parseContext @settings, @settings.context or {}
        @depth = @settings.depth or 1
        @parent = @settings.parent

        @outputs = new Backbone.Collection()

        if @settings.outputs
            _.map @settings.outputs, (value,name) =>
                @outputs.push new exports[name](value)

        else if @depth is 1 then @outputs.push new Console()

        @subscribe true, (event) =>
            @outputs.each (output) -> output.log event
            if @parent then @parent.log event

    child: (settings={}) ->
        settings = _.extend { parent: @, outputs: {}, depth: @depth + 1 }, settings
        return new Logger settings

    parseContext: (contexts...) ->
        contexts = _.map _.flatten(contexts), (context) -> if context.logContext then context.logContext() else context

        context = {}

        tags = _.reduce contexts, ((all, context) ->
            if not context.tags then return all
            else
                tags = h.makeDict(context.tags)
                _.extend all, tags
            ), {}

        if not _.isEmpty tags then context.tags = tags

        data = _.reduce contexts, ((all, context) ->
            if not context.data then return all
            else _.extend all, context.data
            ), {}

        if not _.isEmpty data then context.data = data

        context

    log: (contexts...) ->
        #if msg.constructor is Object then return @event object

        # detect special input format in form of data, tags...
        if contexts.length >=3 and contexts[0].constructor is String and contexts[1].constructor is Object
            if _.every(contexts.slice(2), (context) -> context.constructor is String)
                msg = contexts.shift()
                data = contexts.shift()
                data.msg = msg
                contexts = { data: data, tags: contexts }

        context = @parseContext @context, contexts

        logEntry = _.extend context
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
