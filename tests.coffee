Logger = require './index'

exports.init = (test) ->
    logger = new Logger.Logger()
    logger.log 'lalalla', { bla: 3 }, 'sag','sdgsag'
    test.done()

exports.console = (test) ->
    logger = new Logger.Logger()
    logger.outputs.push new Logger.Console()
    logger.log 'lalalla', { bla: 3 }, 'sag','sdgsag'
    test.done()

exports.udp = (test) ->
    logger = new Logger.Logger()
    logger.outputs.push new Logger.Udp()
    logger.log 'lalalla', { bla: 3 }, 'sag','sdgsag'
    test.done()


    