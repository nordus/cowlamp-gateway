state           = require('../lib/event-codes').state
eventCodes      = require('../lib/event-codes').eventCodes
mongoose        = require('mongoose')
Schema          = require('mongoose').Schema
_               = require('underscore')._
HistoricalTrip  = require './historical-trip'

readingSchema = new Schema                                                                                                                                
  altitude: Number                                                                                                                                 
  speed: Number                                                                                                                                               
  heading: Number                                                                                                                                              
  satellites: Number                                                                                                                                          
  rssi: Number                                                                                                                                               
  hdop: Number
  eventCode:
    type: Number
    required: false
  updateTime: Number                                                                                                                             
  msgType: Number
  seqNumber: Number
  mobileId: String
  geo:
    type:
      type: String
      default: 'Point'
    coordinates: []
,
  strict: false
  toObject:
    transform: (doc, ret, options) ->
      delete ret._id
      ret

readingSchema.index { "mobileId":1, "seqNumber":1 }, { unique:true, dropDups:true }

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
    seqNumbersReceived: []
    highestSpeed: 0

readingSchema.virtual('idleMins').set (v) ->
  @trip.idleMins = v

readingSchema.virtual('vOdometerAtIgnitionOn').set (v) ->
  @trip.vOdometerAtIgnitionOn = v

readingSchema.virtual('vOdometerAtIgnitionOff').set (v) ->
  @trip.vOdometerAtIgnitionOff = v

readingSchema.virtual('event').get ->
  eventCodes["#{@eventCode}"]

readingSchema.virtual('isDeviceGeneratedAlert').get ->
  @event is 'mil_on'    ||
  @event is 'heartbeat' &&
  @state is 'engineOff' &&
  @vBatt < 12.5

readingSchema.virtual('ongoingTrip').get ->
  Boolean @trip.seqNumberOfIgnitionOn

readingSchema.methods.aggregateTripEvents = ->
  historicalTrip =
      start_at        : @trip.updateTimeOfIgnitionOn / 1000
      device_id       : @mobileId
      end_at          : @trip.updateTimeOfIgnitionOff / 1000
      duration        : @trip.updateTimeOfIgnitionOff - @trip.updateTimeOfIgnitionOn
      idle_mins       : @trip.idleMins ? 0
      miles           : @trip.vOdometerAtIgnitionOff - @trip.vOdometerAtIgnitionOn
      ending_mileage  : @trip.vOdometerAtIgnitionOff
      highest_speed   : @trip.highestSpeed
      start_date      : new Date(@trip.updateTimeOfIgnitionOn)
      end_date        : new Date(@trip.updateTimeOfIgnitionOff)

  mobileId = @mobileId

  seqNumberRange =
    $gt: @trip.seqNumberOfIgnitionOn
    $lt: @trip.seqNumberOfIgnitionOff
  
  # reset trip
  delete trips[@mobileId]
 
  @collection.aggregate {
    $match: { mobileId:mobileId, seqNumber:seqNumberRange }
  }, {
    $group: { _id:"$eventCode", num: { "$sum":1 } }
  }, (err, results) ->
      
    results.forEach (result) ->
      historicalTrip["num_#{eventCodes[result._id]}"] = result.num
    
    historicalTrip = _.omit historicalTrip, ['num_heading', 'num_time_with_ignition_on']
    
    HistoricalTrip.create historicalTrip

readingSchema.methods.allSeqNumbersReceived = ->
  # ensure we've received both ignition_on and ignition_off
  if @trip.seqNumberOfIgnitionOn and @trip.seqNumberOfIgnitionOff
    allSeqNumbers = [@trip.seqNumberOfIgnitionOn..@trip.seqNumberOfIgnitionOff]
    # ensure we've received all sequence numbers
    unreceived = _.difference allSeqNumbers, @trip.seqNumbersReceived
    unreceived.length is 0

readingSchema.post 'save', (reading) ->
  if @event is 'ignition_on'
    @trip.seqNumberOfIgnitionOn = @seqNumber
    @trip.updateTimeOfIgnitionOn = @updateTime

  if @ongoingTrip
    @trip.seqNumbersReceived.push @seqNumber
    @trip.highestSpeed = Math.max(@speed, @trip.highestSpeed)
  
  if @event is 'ignition_off'
    @trip.seqNumberOfIgnitionOff = @seqNumber
    @trip.updateTimeOfIgnitionOff = @updateTime

  if @allSeqNumbersReceived()
    @aggregateTripEvents()


module.exports = mongoose.model 'Reading', readingSchema