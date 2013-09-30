request = require 'request'


module.exports = (event, mobileId, updateTime) ->

  alert =
    event         : event
    device_id     : mobileId
    trip_start_at : (updateTime/1000)
    update_time   : (updateTime/1000)

  request.post 'http://zinlot.com/alerts', {form: alert:alert}