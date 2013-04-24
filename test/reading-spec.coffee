Reading = require '../models/reading'
decodedMessages = require('cowlamp').decodedMessages
_ = require('underscore')._

describe 'Reading', ->
  beforeEach ->
    @message = decodedMessages['2']
    @reading = new Reading(@message)