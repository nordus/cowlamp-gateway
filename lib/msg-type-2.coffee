# # Message Type 2

util = require 'util'

module.exports = (msg) ->

  # messageType 5 does not have an eventCode
  util._extend require('./common-2-and-5')(msg),
    eventCode: msg.readUInt8(50)