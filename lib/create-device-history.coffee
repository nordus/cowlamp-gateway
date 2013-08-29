request = require 'request'


module.exports = (reading) ->
  deviceHistory =
    device_id   : reading.mobileId
    dtc_codes   : reading.dtcCodes ? ''
    vbatt       : reading.vBatt

  if process.env.NODE_ENV is 'test'
    reading.emit 'createDeviceHistory', deviceHistory
    request.post 'http://localhost:3000/device_histories', {form: device_history:deviceHistory}
  else
    request.post 'http://app.zinlot.com/device_histories', {form: device_history:deviceHistory}