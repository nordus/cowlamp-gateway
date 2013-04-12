decodePayload = require '../lib/decode-payload'
messages = require('../../cowlamp').messages
decodedMessages = require('../../cowlamp').decodedMessages

describe 'decodePayload', ->
  
  it 'correctly decodes messages', ->
    for msgType, msg of messages
      expect(decodePayload(msg)).toEqual decodedMessages[msgType]