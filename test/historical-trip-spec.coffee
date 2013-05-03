Reading = require '../models/reading'
mongoose = require 'mongoose'
decodePayload = require '../lib/decode-payload'
packets = require './fixtures/raw-trip-1367358482000'

describe 'HistoricalTrip', ->
  beforeEach ->
    mongoose.connect "mongodb://#{process.env.IP}:27017/gateway-test"
    
    # save each reading from dummy trip
    for packet in packets
      payload = decodePayload(new Buffer(packet))
      reading = new Reading(payload)
      reading.save()
  
  describe 'after save', ->
    it 'aggregates trip events', ->
      done()
      true


done = ->
  setTimeout ->
    mongoose.connection.db.dropDatabase ->
      mongoose.disconnect()
  , 1000