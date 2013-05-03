Schema  = require('jugglingdb').Schema
db      = require('../lib/db')

historicalTripSchema =
  start_at: Number
  device_id: String
  end_at: Number
  duration: Number

module.exports = db.postgresql.define 'historical_trips', historicalTripSchema