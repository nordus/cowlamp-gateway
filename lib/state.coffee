eventCodes = require './event-codes'

module.exports = (eventCode) ->

  event = eventCodes["#{eventCode}"]
  
  return 'engineOn' if event in [
    'ignition_on'
    'time_with_ignition_on'
    'heading'
    'high_speed'
    'rpm'
    'idle'
    'accel_1'
    'accel_2'
    'brake_1'
    'brake_2'
    'corner_l_1'
    'corner_l_2'
    'corner_r_1'
    'corner_r_2'
  ]
  
  return 'engineOff' if event in [
    'ignition_off'
    'time_with_ignition_off'
  ]
  
  return 'info'