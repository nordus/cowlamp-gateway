state       = require './state'
eventCodes  = require './event-codes'

devices = {}

module.exports = (reading, collection) ->

  mobileId      = reading.mobileId
  device        = devices[mobileId] ?= {}
  prevState     = device.state
  newState      = state(reading.eventCode)
  stateChanged  = prevState isnt newState 
  device.state  = newState
  
  if stateChanged
  
    if newState is 'engineOn'
      device.tripStartAt = reading.updateTime
      
    if newState is 'engineOff' and device.tripStartAt
      collection.aggregate {
        $match: { mobileId:mobileId, updateTime: { $gt:device.tripStartAt } }
      }, {
        $group: { _id:"$eventCode", num: { "$sum":1 } }
      }, (err, results) ->
        historical_trip =
          start_at  : device.tripStartAt
          device_id : mobileId
          end_at    : reading.updateTime
          duration  : reading.updateTime - device.tripStartAt
          
        results.forEach (result) ->
          historical_trip["num_#{eventCodes[result._id]}"] = result.num
        
        console.log historical_trip