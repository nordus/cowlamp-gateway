Reading         = require '../models/reading'
mongoose        = require 'mongoose'
decodePayload   = require '../lib/decode-payload'
packets         = require './fixtures/raw-trip-1367358482000'
tripEvents      = require './fixtures/historical-trip-1367358482000'
db              = require '../lib/db'
_               = require('underscore')._

describe 'HistoricalTrip', ->
  beforeEach ->

    mongoose.connect db.mongoUrl

    tripComplete = (historicalTrip) =>
      @historicalTrip = historicalTrip

    for packet in packets
      payload = decodePayload(new Buffer(packet))
      reading = new Reading(payload)
      reading.on 'tripComplete', tripComplete
      reading.save()

  it 'works', ->
    waitsFor ->
      @historicalTrip
    , 10000

    runs ->
      # start_date and end_date are dependent on local system's timezone
      historicalTrip = _.omit @historicalTrip, ['start_date', 'end_date']
      expect(historicalTrip).toEqual tripEvents
      done()


done = ->
  mongoose.connection.db.dropDatabase ->
    mongoose.disconnect()

  db.postgresql.disconnect()