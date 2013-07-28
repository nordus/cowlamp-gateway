request = require 'request'
_ = require('underscore')._


module.exports = (mobileId, geofenceId, tripStartAt) ->

  tripStartAt ?= (new Date().getTime())

  geofence_violation =
    trip_start_at : (tripStartAt/1000)
    device_id     : mobileId
    geofence_id   : geofenceId

  request.post 'http://admin.zinmatics.com/geofence_violations', {form: geofence_violation:geofence_violation}