Reading         = require '../models/reading'
mongoose        = require 'mongoose'
decodePayload   = require '../lib/decode-payload'
packets         = require './fixtures/raw-trip-1367358482000'
tripEvents      = require './fixtures/historical-trip-1367358482000'
db              = require '../lib/db'
postgresql      = db.postgresql
HistoricalTrip  = require '../models/historical-trip'
_               = require('underscore')._

describe 'HistoricalTrip', ->
  beforeEach ->
    
    mongoose.connect db.mongoUrl
    
    postgresql.on 'connected', ->
      HistoricalTrip.destroyAll ->
        # save each reading from dummy trip
        for packet in packets
          payload = decodePayload(new Buffer(packet))
          reading = new Reading(payload)
          reading.save()
        
        setTimeout ->
          asyncSpecDone()
        , 1000
        
    asyncSpecWait()

  describe 'after all trip readings are saved to db', ->
    it 'saves historical_trip to db', ->
      HistoricalTrip.count (err, historicalTripCount) ->
        expect(historicalTripCount).toBe 1
        
      HistoricalTrip.all (err, historicalTrips) ->
        historicalTrip = _.omit historicalTrips[0].toJSON(), ['id', 'start_date', 'end_date', 'created_at', 'updated_at']
        expect(historicalTrip).toEqual tripEvents
        done()
        asyncSpecDone()
      
      asyncSpecWait()


done = ->
  mongoose.connection.db.dropDatabase ->
    mongoose.disconnect()
    
  
  db.postgresql.disconnect()