# # Geofence

mongoose        = require('mongoose')
Schema          = require('mongoose').Schema

geofenceSchema = new Schema
  geo:
    type:
      type: String
      default: 'Point'
    coordinates: []
  color:
    type: String
    default: '#0000ff'
  name: String
  mobileId: String
,
  strict: false
  toObject:
    transform: (doc, ret, options) ->
      delete ret._id
      ret

geofenceSchema.index { "mobileId":1, "geo":"2dsphere" }

geofenceSchema.virtual('latitude').set (v) ->
  @geo.coordinates[1] = v

geofenceSchema.virtual('longitude').set (v) ->
  @geo.coordinates[0] = v

module.exports = mongoose.model 'Geofence', geofenceSchema