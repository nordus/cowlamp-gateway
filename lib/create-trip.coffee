request = require 'request'
_ = require('underscore')._


module.exports = (historical_trip) ->
  historical_trip = _.omit(historical_trip, ['start_date', 'end_date', 'num_heartbeat'])
  request.post 'http://admin.zinmatics.com/historical_trips', {form: historical_trip:historical_trip}