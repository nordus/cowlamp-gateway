util = require 'util'

engineOn =
  '20': 'ignition_on'
  '21': 'time_with_ignition_on'
  '22': 'heading'
  '23': 'speed_event'
  '24': 'rpm_event'
  '25': 'idle'
  '40': 'hard_accel'
  '41': 'very_hard_accel'
  '42': 'hard_brake'
  '43': 'very_hard_brake'
  '44': 'corner_l'
  '45': 'hard_corner_l'
  '46': 'corner_r'
  '47': 'hard_corner_r'
  '50': 'enter_geo_zone'
  '51': 'exit_geo_zone'

engineOff =
  '30': 'ignition_off'
  '31': 'time_with_ignition_off'

info =
  '10': 'power_up'
  '11': 'obd_scan'
  '26': 'heartbeat'
  '100': 'mil_on'
  '101': 'mil_off'

exports.state = (eventCode) ->
  if engineOn["#{eventCode}"]
    return 'engineOn'
  
  if engineOff["#{eventCode}"]
    return 'engineOff'

eventCodes = {}
util._extend eventCodes, engineOn
util._extend eventCodes, engineOff
util._extend eventCodes, info

exports.eventCodes = eventCodes