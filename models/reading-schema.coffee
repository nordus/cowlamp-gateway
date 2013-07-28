Schema = require('mongoose').Schema

module.exports = new Schema
  altitude: Number
  speed: Number
  heading: Number
  satellites: Number
  rssi: Number
  hdop: Number
  eventCode:
    type: Number
    required: false
  updateTime: Number
  msgType: Number
  seqNumber: Number
  mobileId: String
  geofenceId: Number
  geo:
    type:
      type: String
      default: 'Point'
    coordinates: []
,
  strict: false
  toObject:
    transform: (doc, ret, options) ->
      delete ret._id
      ret