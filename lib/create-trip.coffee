request = require 'request'
_ = require('underscore')._


module.exports = (historical_trip) ->
  historical_trip = _.omit(historical_trip, ['start_date', 'end_date', 'num_heartbeat', 'num_ignition_on', 'num_ignition_off'])
  request.post 'http://app.zinlot.com/historical_trips', {form: historical_trip:historical_trip}