decodePayload = require '../lib/decode-payload'
messages = require('cowlamp').messages
decodedMessages = require('cowlamp').decodedMessages
_ = require('underscore')._

describe 'decodePayload', ->
  
  it 'correctly decodes messages', ->
    for msgType, msg of messages
      expect(_.omit(decodePayload(msg).toObject(),['rawPacket'])).toEqual decodedMessages[msgType]