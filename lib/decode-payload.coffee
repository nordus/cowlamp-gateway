# # Decode Payload

util = require 'util'
ack = require './ack'
Reading = require '../models/reading'
Pusher = require 'pusher'
pusherConfig = require "#{__dirname}/pusher-config.json"

# parse functions for each message type
parse =
  '2':  require('./msg-type-2')
  '5':  require('./msg-type-5')
  '10': require('./msg-type-10')

# `msg` and `rinfo` are params passed to `message` event callback
module.exports = (msg, rinfo) ->

  # attributes common to all message types
  common =
    mobileId:   msg.slice(2, 7).toString('hex')
    msgType:    msg.readUInt8 10
    seqNumber:  msg.readUInt16BE 11
    updateTime: (msg.readUInt32BE(13) * 1000)
    rawPacket:  msg.toString('hex').toUpperCase().match(/\w{2}/g).join ' '

  # attributes specific to message type
  parsed = parse["#{common.msgType}"](msg)

  pusher = new Pusher(pusherConfig)

  logTrip = (trip) =>
    console.log trip

      # merge common and message specific attributes
  reading = new Reading(util._extend parsed, common)
  reading.on 'tripComplete', logTrip

  pusher.trigger 'gateway', 'message', reading.toObject()

  reading.save()

  # do not ack or save if in development
  if process.env.NODE_ENV is 'test'
    return reading
  else
    ack(msg, rinfo)