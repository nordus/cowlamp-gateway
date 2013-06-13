# # Reading

state           = require('../lib/event-codes').state
eventCodes      = require('../lib/event-codes').eventCodes
mongoose        = require('mongoose')
readingSchema   = require('./reading-schema')
_               = require('underscore')._
HistoricalTrip  = require './historical-trip'

readingSchema.index { "mobileId":1, "seqNumber":1 }, { unique:true, dropDups:true }
readingSchema.index { "mobileId":1, "geo":"2dsphere" }

readingSchema.virtual('latitude').set (v) ->
  @geo.coordinates[1] = v

readingSchema.virtual('longitude').set (v) ->
  @geo.coordinates[0] = v

# example 'engineOn', 'engineOff'
readingSchema.virtual('state').get ->
  state(@eventCode)

trips = {}
readingSchema.virtual('trip').get ->
  trips[@mobileId] ?=
    highestSpeed: 0

readingSchema.virtual('idleSeconds').set (v) ->
  @trip.idleSeconds = v

readingSchema.virtual('vOdometerAtIgnitionOn').set (v) ->
  @trip.vOdometerAtIgnitionOn = v

readingSchema.virtual('vOdometerAtIgnitionOff').set (v) ->
  @trip.vOdometerAtIgnitionOff = v

readingSchema.virtual('event').get ->
  eventCodes["#{@eventCode}"]

readingSchema.virtual('ongoingTrip').get ->
  Boolean @trip.seqNumberOfIgnitionOn

readingSchema.virtual('alertEventType').get -> switch
  # 1 - Battery Low
  when @event is 'heartbeat' && @state is 'engineOff' && @vBatt < 12.5 then 1

  # 3 - Engine Lights ON
  when @dtcCodes or @event is 'mil_on' then 3
  
  else undefined

readingSchema.virtual('historicalTrip').get -> {
  start_at        : @trip.updateTimeOfIgnitionOn / 1000
  device_id       : @mobileId
  end_at          : @trip.updateTimeOfIgnitionOff / 1000
  duration        : @trip.updateTimeOfIgnitionOff - @trip.updateTimeOfIgnitionOn
  idle_seconds    : @trip.idleSeconds ? 0
  miles           : @trip.vOdometerAtIgnitionOff - @trip.vOdometerAtIgnitionOn
  ending_mileage  : @trip.vOdometerAtIgnitionOff
  highest_speed   : @trip.highestSpeed
  start_date      : new Date(@trip.updateTimeOfIgnitionOn)
  end_date        : new Date(@trip.updateTimeOfIgnitionOff)
}

readingSchema.methods.handleAlertsAndHistory = ->
  if @alertEventType
    Alert.create
      event_type: @alertEventType
      device_id: @mobileId
      update_time: @updateTime
      trip_start_at: @trip.updateTimeOfIgnitionOn / 1000
      latitude: @latitude
      longitude: @longitude
  
  if @vin or @dtcCodes
    DeviceHistory.create
      obd_vin: @vin ? null
      dtc_codes: @dtcCodes ? null
      device_id: @mobileId

readingSchema.methods.createTrip = ->
  historicalTrip  = @historicalTrip
  mobileId        = @mobileId
  seqNumberRange =
    $gt: @trip.seqNumberOfIgnitionOn
    $lt: @trip.seqNumberOfIgnitionOff
 
  @collection.aggregate {
    $match: { mobileId:mobileId, seqNumber:seqNumberRange }
  }, {
    $group: { _id:"$eventCode", num: { "$sum":1 } }
  }, (err, results) =>
      
    results.forEach (result) ->
      historicalTrip["num_#{eventCodes[result._id]}"] = result.num
    
    historicalTrip = _.omit historicalTrip, ['num_heading', 'num_time_with_ignition_on']

    if process.env.NODE_ENV is 'test'
      @emit 'tripComplete', historicalTrip
      setTimeout =>
        delete trips[@mobileId]
      , 13

    else
      HistoricalTrip.create historicalTrip, (err, ht) ->
        delete trips[@mobileId]

readingSchema.methods.createTripIfAllSeqNumbersReceived = ->
  # ensure we've received both ignition_on and ignition_off
  if @trip.seqNumberOfIgnitionOn and @trip.seqNumberOfIgnitionOff
    totalSeqNumbers = [@trip.seqNumberOfIgnitionOn..@trip.seqNumberOfIgnitionOff].length

    @collection.count
      seqNumber:
        $gte: @trip.seqNumberOfIgnitionOn
        $lte: @trip.seqNumberOfIgnitionOff
    , (err, count) =>

        # create trip if all sequence numbers received
        @createTrip() if count == totalSeqNumbers

readingSchema.post 'save', (reading) ->
  if @event is 'ignition_on'
    @trip.seqNumberOfIgnitionOn   = @seqNumber
    @trip.updateTimeOfIgnitionOn  = @updateTime

  if @ongoingTrip
    @trip.highestSpeed = Math.max(@speed, @trip.highestSpeed)
  
  if @event is 'ignition_off'
    @trip.seqNumberOfIgnitionOff  = @seqNumber
    @trip.updateTimeOfIgnitionOff = @updateTime

  @createTripIfAllSeqNumbersReceived()


module.exports = mongoose.model 'Reading', readingSchema
