# # Decode Payload

ack = require './ack'

# parse functions for each message type
parse =
  '2':  require('./msg-type-2')
  '4':  require('./msg-type-4')

# `msg` and `rinfo` are params passed to `message` event callback
module.exports = (msg, rinfo) ->

  # attributes common to all message types
  reading =
    mobileId:   msg.slice(2, 7).toString('hex')
    msgType:    msg.readUInt8 10
    seqNumber:  msg.readUInt16BE 11
    updateTime: (msg.readUInt32BE(13) * 1000)
    timeOfFix:  (msg.readUInt32BE(17) * 1000)
    # convert latitude, longitude to decimal
    latitude:   (msg.readInt32BE(21) / 10000000)
    longitude:  (msg.readInt32BE(25) / 10000000)
    # cm to ft
    altitude:   (msg.readInt32BE(29) * 0.0328084)
    # cm/second to mph
    speed:      (msg.readUInt32BE(33) * 0.022369362920544023)
    heading:    msg.readUInt16BE(37)
    satellites: msg.readUInt8(39)
    fixStatus:  msg.readUInt8(40)
    carrier:    msg.readUInt16BE(41)
    rssi:       msg.readInt16BE(43)
    commState:  msg.readUInt8(45).toString(2)
    # to units of 0.1
    hdop:       (msg.readUInt8(46) / 10)
    inputStates:  msg.readUInt8(47).toString(2)
    unitStatus: msg.readUInt8(48).toString(2)

  # add attributes specific to message type
  parse["#{reading.msgType}"](msg, reading)

  # do not ack or save if in development
  if process.env.NODE_ENV is 'test'
    return reading
  else
    ack(msg, rinfo)