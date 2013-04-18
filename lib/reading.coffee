state = require './state'
eventCodes = require './event-codes'
mongoose = require('mongoose')
Schema = require('mongoose').Schema
mongoose.connect process.env.MONGOHQ_URL

readingSchema = new Schema
  latitude: Number                                                                                                                                    
  longitude: Number                                                                                                                                
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
  mobileId: String
,
  strict: false
  toObject:
    transform: (doc, ret, options) ->
      delete ret._id
      ret

readingSchema.virtual('state').get ->
  state(@eventCode)

devices = {}
readingSchema.virtual('device').get ->
  devices[@mobileId] ?= {}

readingSchema.virtual('prevState').get ->
  @device.state

readingSchema.methods.aggregateTripEvents = ->
  tripStartAt = @device.tripStartAt
  mobileId    = @mobileId
  updateTime  = @updateTime
  @collection.aggregate {
    $match: { mobileId:mobileId, updateTime: { $gt:tripStartAt, $lt:updateTime } }
  }, {
    $group: { _id:"$eventCode", num: { "$sum":1 } }
  }, (err, results) ->
    historical_trip =
      start_at  : tripStartAt
      device_id : mobileId
      end_at    : updateTime
      duration  : updateTime - tripStartAt
      
    results.forEach (result) ->
      historical_trip["num_#{eventCodes[result._id]}"] = result.num
    
    console.log historical_trip

readingSchema.post 'save', (reading) ->
  stateChanged          = reading.state isnt reading.prevState
  reading.device.state  = reading.state
  
  if stateChanged

    if reading.state is 'engineOn'
      reading.device.tripStartAt = reading.updateTime
    
    if reading.state is 'engineOff' and reading.device.tripStartAt
      reading.aggregateTripEvents()


module.exports = mongoose.model 'Reading', readingSchema