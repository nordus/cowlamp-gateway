request = require 'request'


module.exports = (mobileId, eventType, tripStartAt) ->

  tripStartAt ?= (new Date().getTime())

  alert =
    trip_start_at : (tripStartAt/1000)
    device_id     : mobileId
    event_type    : eventType

  request.post 'http://admin.zinmatics.com/alerts', {form: alert:alert}