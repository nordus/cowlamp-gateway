Schema  = require('jugglingdb').Schema
db      = require('../lib/db')

default0 =
  type: Number
  default: 0

historicalTripSchema =
  start_at: Number
  device_id: String
  end_at: Number
  duration: Number
  time_zone:
    type: String
    default: 'America/Phoenix'
  qos_flags: default0
  num_corner_l: default0
  num_corner_r: default0
  num_very_hard_brake: default0
  num_very_hard_accel: default0
  num_hard_corner_l: default0
  num_hard_corner_r: default0
  fuel_gal_start:
    type: Number
    default: 0.0
  fuel_gal_end:
    type: Number
    default: 0.0
  status: default0
  key_fob_id: default0
  miles: Number
  num_hard_brake: default0
  num_hard_accel: default0
  num_speed_event: default0
  num_rpm_event: default0
  ending_mileage: Number
  created_at:
    type: Date
    default: new Date()
  updated_at:
    type: Date
    default: new Date()
  start_date: Date
  highest_speed: Number
  idle_mins: Number
  end_date: Date

module.exports = db.postgresql.define 'historical_trips', historicalTripSchema