request = require 'request'
_ = require('underscore')._


module.exports = (mobileId, geofenceId, tripStartAt) ->
  geofence_violation =
    trip_start_at : tripStartAt ? (new Date().getTime())
    device_id     : mobileId
    geofence_id   : geofenceId

  console.log '\n\n geofence_violation:'
  console.log geofence_violation

  request.post 'http://admin.zinmatics.com/geofence_violations', {form: geofence_violation:geofence_violation}