Reading         = require '../models/reading'
mongoose        = require 'mongoose'
decodePayload   = require '../lib/decode-payload'
packets         = require './fixtures/raw-trip-1367358482000'
tripEvents      = require './fixtures/historical-trip-1367358482000'
db              = require '../lib/db'
_               = require('underscore')._

describe 'HistoricalTrip', ->
  beforeEach ->

    tripComplete = (historicalTrip) =>
      @historicalTrip = historicalTrip
      asyncSpecDone()

    for packet in packets
#      payload = decodePayload(new Buffer(packet))
      reading = decodePayload(new Buffer(packet))
#      reading = new Reading(payload)
      reading.on 'tripComplete', tripComplete
#      reading.save()

    asyncSpecWait()

  it 'works', ->
    historicalTrip = _.omit @historicalTrip, ['start_date', 'end_date']
    expect(historicalTrip).toEqual tripEvents
    done()


done = ->
  mongoose.connection.db.dropDatabase()