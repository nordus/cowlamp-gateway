request = require 'request'


module.exports = (event, mobileId, geofenceId, tripStartAt, updateTime) ->

  tripStartAt ?= (new Date().getTime())

  geofence_violation =
    event         : event
    device_id     : mobileId
    geofence_id   : geofenceId
    trip_start_at : (tripStartAt/1000)
    update_time   : (updateTime/1000)

  request.post 'http://zinlot.com/geofence_violations', {form: geofence_violation:geofence_violation}