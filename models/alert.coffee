Schema  = require('jugglingdb').Schema
db      = require('../lib/db')

alertSchema =
  checked:
    type: Boolean
    default: false
  device_id: String
  update_time: Number
  trip_start_at: Number
  latitude: Number
  longitude: Number
  event_type: Number
  geofence_id:
    type: String
    default: null
  time_inside_geofence:
    type: Number
    default: null
  created_at:
    type: Date
    default: new Date()
  updated_at:
    type: Date
    default: new Date()

module.exports = db.postgresql.define 'alerts', alertSchema
