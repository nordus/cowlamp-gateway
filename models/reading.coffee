state       = require('../lib/event-codes').state
eventCodes  = require('../lib/event-codes').eventCodes
mongoose    = require('mongoose')
Schema      = require('mongoose').Schema
_           = require('underscore')._

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

readingSchema.virtual('event').get ->
  eventCodes["#{@eventCode}"]

readingSchema.virtual('isDeviceGeneratedAlert').get ->
  @event is 'mil_on'    ||
  @event is 'heartbeat' &&
  @state is 'engineOff' &&
  @vBatt < 12.5

readingSchema.methods.aggregateTripEvents = ->
  mobileId                = @mobileId
  seqNumberOfIgnitionOn   = @trip.seqNumberOfIgnitionOn
  seqNumberOfIgnitionOff  = @trip.seqNumberOfIgnitionOff
  updateTimeOfIgnitionOn  = @trip.updateTimeOfIgnitionOn
  updateTimeOfIgnitionOff = @trip.updateTimeOfIgnitionOff
  
  # reset trip
  delete trips[@mobileId]
 
  @collection.aggregate {
    $match: { mobileId:mobileId, seqNumber: { $gt:seqNumberOfIgnitionOn, $lt:seqNumberOfIgnitionOff } }
  }, {
    $group: { _id:"$eventCode", num: { "$sum":1 } }
  }, (err, results) ->
    historicalTrip =
      start_at  : updateTimeOfIgnitionOn
      device_id : mobileId
      end_at    : updateTimeOfIgnitionOff
      duration  : updateTimeOfIgnitionOff - updateTimeOfIgnitionOn
      
    results.forEach (result) ->
      historicalTrip["num_#{eventCodes[result._id]}"] = result.num
    
    console.log historicalTrip

readingSchema.methods.allSeqNumbersReceived = ->
  # ensure we've received both ignition_on and ignition_off
  if @trip.seqNumberOfIgnitionOn and @trip.seqNumberOfIgnitionOff
    allSeqNumbers = [@trip.seqNumberOfIgnitionOn..@trip.seqNumberOfIgnitionOff]
    # ensure we've received all sequence numbers
    unreceived = _.difference allSeqNumbers, @trip.seqNumbersReceived
    unreceived.length is 0

readingSchema.post 'save', (reading) ->
  if reading.state is 'engineOn' or reading.event is 'ignition_off'
    @trip.seqNumbersReceived.push reading.seqNumber

  if reading.event is 'ignition_on'
    reading.trip.seqNumberOfIgnitionOn = reading.seqNumber
    reading.trip.updateTimeOfIgnitionOn = reading.updateTime
  
  if reading.event is 'ignition_off'
    reading.trip.seqNumberOfIgnitionOff = reading.seqNumber
    reading.trip.updateTimeOfIgnitionOff = reading.updateTime

  if reading.allSeqNumbersReceived()
    reading.aggregateTripEvents()


module.exports = mongoose.model 'Reading', readingSchema