# # Reading

state           = require('../lib/event-codes').state
eventCodes      = require('../lib/event-codes').eventCodes
mongoose        = require('mongoose')
readingSchema   = require('./reading-schema')
createGeofenceViolation = require '../lib/create-geofence-violation'
createDeviceHistory = require '../lib/create-device-history'
_               = require('underscore')._
Pusher = require 'pusher'
pusherConfig = require "../lib/pusher-config.json"

# when device is power cycled, or seqNumber hits 65535 it loops back to 0
#readingSchema.index { "mobileId":1, "seqNumber":1 }, { unique:true, dropDups:true }
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
    seqNumbersRcvd:[]

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

readingSchema.methods.closeTrip = ->
  delete trips[@mobileId]

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

    pusher = new Pusher(pusherConfig)
    pusher.trigger 'gateway', 'message', historicalTrip

    console.log '.. PUSHING TRIP TO PUSHER'
    console.log historicalTrip

    #    if process.env.NODE_ENV is 'test'
    @emit 'tripComplete', historicalTrip
    setTimeout =>
      @closeTrip()
    , 13

#    else
#      HistoricalTrip.create historicalTrip, (err, ht) ->
#        delete trips[@mobileId]

readingSchema.methods.createTripIfAllSeqNumbersReceived = ->
  # ensure we've received both ignition_on and ignition_off
  if @trip.seqNumberOfIgnitionOn and @trip.seqNumberOfIgnitionOff
#    totalSeqNumbers = [@trip.seqNumberOfIgnitionOn..@trip.seqNumberOfIgnitionOff].length
    allSeqNumbers = [@trip.seqNumberOfIgnitionOn..@trip.seqNumberOfIgnitionOff]

    # ensure we've received all sequence numbers
    # example:
    #
    #   @trip.seqNumbersRcvd = [10, 11, 12]

    #   seqNumberOfIgnitionOn = 10
    #   seqNumberOfIgnitionOff = 12
    #
    #  allSeqNumbers = [seqNumberOfIgnitionOn..seqNumberOfIgnitionOff]
    #   #=> [10, 11, 12]
    #
    #  _.difference(allSeqNumbers, seqNumbersRcvd)
    #   #=> 0
    unreceived = _.difference allSeqNumbers, @trip.seqNumbersRcvd

    @createTrip()  if unreceived.length is 0

#    @collection.count
#      seqNumber:
#        $gte: @trip.seqNumberOfIgnitionOn
#        $lte: @trip.seqNumberOfIgnitionOff
#    , (err, count) =>

# create trip if all sequence numbers received
#        @createTrip() if count == totalSeqNumbers

readingSchema.post 'save', (reading) ->
  if @event is 'ignition_on'

    # close previous trip if needed
    @closeTrip()  if @trip.seqNumbersRcvd.length

    @trip.seqNumberOfIgnitionOn   = @seqNumber
    @trip.updateTimeOfIgnitionOn  = @updateTime

  if @ongoingTrip
    @trip.highestSpeed = Math.max(@speed, @trip.highestSpeed)
    @trip.seqNumbersRcvd.push @seqNumber

  if @event is 'ignition_off'
    @trip.seqNumberOfIgnitionOff  = @seqNumber
    @trip.updateTimeOfIgnitionOff = @updateTime

  if @event is 'exit_geo_zone'
    createGeofenceViolation 'GEOFENCE_EXIT', @mobileId, @geofenceId, @trip.updateTimeOfIgnitionOn, @updateTime

  if @event is 'enter_geo_zone'
    createGeofenceViolation 'GEOFENCE_ENTER', @mobileId, @geofenceId, @trip.updateTimeOfIgnitionOn, @updateTime

  if @event is 'heartbeat'
    createDeviceHistory(reading)

  @createTripIfAllSeqNumbersReceived()


module.exports = mongoose.model 'Reading', readingSchema