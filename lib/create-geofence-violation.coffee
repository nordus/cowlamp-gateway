request = require 'request'
_ = require('underscore')._


module.exports = (reading, trip) ->
  geofence_violation =
    trip_start_at : trip.updateTimeOfIgnitionOn ? (new Date().getTime())
    device_id     : reading.mobileId
    geofence_id   : reading.geofenceId

  console.log '\n\n geofence_violation:'
  console.log geofence_violation

  request.post 'http://admin.zinmatics.com/geofence_violations', {form: geofence_violation:geofence_violation}