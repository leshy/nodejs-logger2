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


exports.initContext = (test) ->
    logger = new Logger.Logger
        data:
            a: 1
            b: 2
        tags: [ 'bla', 'blu' ],
        context:
            tags: { k: true }
            data:
                b: 3
                c: 4

    test.deepEqual logger.context.data, { a: 1, b: 3, c: 4 }
    test.deepEqual logger.context.tags, { bla: true, blu: true, k: true }
    test.done()

exports.childContext = (test) ->
    parent = new Logger.Logger
        tags: [ 'bla' ]
        data: { a: 1 }

    child = parent.child data: { b: 2 }, tags: [ 'bla2' ]

    test.equals child.parent, parent


    child.subscribe true, (event) ->
        test.deepEqual event, { tags: { bla2: true, bla3: true }, data: { b: 2, c: 3, msg: 'test message' } }

    parent.subscribe true, (event) ->
        test.deepEqual event, { tags: { bla: true, bla2: true, bla3: true }, data: { a: 1, b: 2, c: 3, msg: 'test message' } }
        test.done()

    child.log "test message", { c: 3 }, 'bla3'
