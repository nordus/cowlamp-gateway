# # Message Type 2

util = require 'util'

module.exports = (msg) ->
  
  parsed = require('./common-2-and-5')(msg) 
  parsed.eventCode = msg.readUInt8(50)

  if parsed.eventCode is 20
    parsed.vOdometerAtIgnitionOn  = (msg.readUInt32BE(53) * 0.000621371)

  if parsed.eventCode is 30
    parsed.vOdometerAtIgnitionOff = (msg.readUInt32BE(53) * 0.000621371)
  
  return parsed