// Generated by CoffeeScript 1.7.1
(function() {
  var Logger;

  Logger = require('./index');

  exports.init = function(test) {
    var logger;
    logger = new Logger.Logger();
    logger.log('lalalla', {
      bla: 3
    }, 'sag', 'sdgsag');
    return test.done();
  };

  exports.console = function(test) {
    var logger;
    logger = new Logger.Logger();
    logger.outputs.push(new Logger.Console());
    logger.log('lalalla', {
      bla: 3
    }, 'sag', 'sdgsag');
    return test.done();
  };

  exports.udp = function(test) {
    var logger;
    logger = new Logger.Logger();
    logger.outputs.push(new Logger.Udp());
    logger.log('lalalla', {
      bla: 3
    }, 'sag', 'sdgsag');
    return test.done();
  };

  exports.initContext = function(test) {
    var logger;
    logger = new Logger.Logger({
      data: {
        a: 1,
        b: 2
      },
      tags: ['bla', 'blu'],
      context: {
        tags: {
          k: true
        },
        data: {
          b: 3,
          c: 4
        }
      }
    });
    test.deepEqual(logger.context.data, {
      a: 1,
      b: 3,
      c: 4
    });
    test.deepEqual(logger.context.tags, {
      bla: true,
      blu: true,
      k: true
    });
    return test.done();
  };

  exports.childContext = function(test) {
    var child, parent;
    parent = new Logger.Logger({
      tags: ['bla'],
      data: {
        a: 1
      }
    });
    child = parent.child({
      data: {
        b: 2
      },
      tags: ['bla2']
    });
    test.equals(child.parent, parent);
    child.subscribe(true, function(event) {
      return test.deepEqual(event, {
        tags: {
          bla2: true,
          bla3: true
        },
        data: {
          b: 2,
          c: 3,
          msg: 'test message'
        }
      });
    });
    parent.subscribe(true, function(event) {
      test.deepEqual(event, {
        tags: {
          bla: true,
          bla2: true,
          bla3: true
        },
        data: {
          a: 1,
          b: 2,
          c: 3,
          msg: 'test message'
        }
      });
      return test.done();
    });
    return child.log("test message", {
      c: 3
    }, 'bla3');
  };

}).call(this);
