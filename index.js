// Generated by CoffeeScript 1.8.0
(function() {
  var Backbone, Console, Logger, Udp, UdpGun, colors, fs, h, os, settings, subscriptionMan, _,
    __slice = [].slice;

  _ = require('underscore');

  Backbone = require('backbone4000');

  h = require('helpers');

  subscriptionMan = require('subscriptionman2');

  colors = require('colors');

  UdpGun = require('udp-client');

  os = require('os');

  fs = require('fs');

  settings = {
    logstash: {
      host: 'localhost',
      port: "6000",
      extendPacket: {
        type: 'log',
        host: os.hostname()
      }
    }
  };

  Logger = exports.Logger = subscriptionMan.basic.extend4000({
    initialize: function(settings) {
      if (settings == null) {
        settings = {};
      }
      this.settings = _.extend({}, settings);
      this.outputs = new Backbone.Collection();
      this.subscribe(true, (function(_this) {
        return function(event) {
          return _this.outputs.each(function(output) {
            return output.log(event);
          });
        };
      })(this));
      if (!this.settings.outputs) {
        return this.outputs.push(new Console());
      } else {
        return _.map(this.settings.outputs, (function(_this) {
          return function(value, name) {
            return _this.outputs.push(new exports[name](value));
          };
        })(this));
      }
    },
    log: function() {
      var data, logEntry, msg, tags;
      msg = arguments[0], data = arguments[1], tags = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      if (data == null) {
        data = {};
      }
      _.map(h.array(this.settings.tags), function(tag) {
        return tags.push(tag);
      });
      logEntry = _.extend({}, {
        tags: tags,
        message: msg
      }, data);
      return this.event(logEntry);
    }
  });

  Console = exports.Console = Backbone.Model.extend4000({
    name: 'console',
    initialize: function() {
      return this.startTime = process.hrtime()[0];
    },
    parseTags: function(tags) {
      return _.map(tags, function(tag) {
        if (tag === 'fail' || tag === 'error') {
          return colors.red(tag);
        }
        if (tag === 'pass' || tag === 'ok') {
          return colors.green(tag);
        }
        return colors.yellow(tag);
      });
    },
    log: function(logEvent) {
      var hrtime, tags;
      hrtime = process.hrtime();
      tags = this.parseTags(logEvent.tags);
      return console.log(colors.grey(new Date()) + "\t" + colors.green("" + (hrtime[0] - this.startTime) + "." + hrtime[1]) + "\t " + tags.join(', ') + "\t⋅\t" + logEvent.message);
    }
  });

  Udp = exports.Udp = Backbone.Model.extend4000({
    name: 'udp',
    initialize: function(settings) {
      this.settings = settings != null ? settings : {
        host: 'localhost',
        port: 6000
      };
      this.gun = new UdpGun(this.settings.port, this.settings.host);
      return this.hostname = os.hostname();
    },
    log: function(logEvent) {
      return this.gun.send(new Buffer(JSON.stringify(_.extend({
        type: 'nodelogger',
        host: this.hostname
      }, this.settings.extendPacket || {}, logEvent))));
    }
  });

}).call(this);
