Reading = require '../models/reading'
decodedMessages = require('cowlamp').decodedMessages
_ = require('underscore')._
mongoose = require 'mongoose'

describe 'Reading', ->
  beforeEach ->
    mongoose.connect 'mongodb://localhost/gateway-test'
    
    @message = decodedMessages['2']
    @reading = new Reading(@message)
  
  afterEach ->
    mongoose.disconnect()