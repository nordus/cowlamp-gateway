#Reading = require '../models/reading'
#mongoose = require 'mongoose'
#decodePayload = require '../lib/decode-payload'
#packets = require './fixtures/raw-trip-1367358482000'
#
#describe 'Reading', ->
  #beforeEach ->
    #mongoose.connect "mongodb://#{process.env.IP}:27017/gateway-test"
    #
    #for packet in packets
      #payload = decodePayload(new Buffer(packet))
      #reading = new Reading(payload)
      #reading.save()
  #
  #afterEach ->
    #setTimeout ->
      #mongoose.disconnect()
    #, 1000
  #
  #describe 'after save', ->
    #it 'aggregates trip events', ->
      #true