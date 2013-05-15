Schema  = require('jugglingdb').Schema
db      = require('../lib/db')

deviceHistorySchema =
  obd_vin: String
  device_id: String
  created_at:
    type: Date
    default: new Date()
  updated_at:
    type: Date
    default: new Date()

module.exports = db.postgresql.define 'device_histories', deviceHistorySchema
