request = require 'request'
_ = require('underscore')._
Pusher = require 'pusher'
pusherConfig = require "#{__dirname}/pusher-config.json"


module.exports = (historical_trip) ->
  historical_trip = _.omit(historical_trip, ['start_date', 'end_date', 'num_heartbeat', 'num_ignition_on', 'num_ignition_off'])
  console.log 'historical trip:'
  console.log historical_trip

  pusher = new Pusher(pusherConfig)
  pusher.trigger 'gateway', 'message', historical_trip

  request.post 'http://app.zinlot.com/historical_trips', {form: historical_trip:historical_trip}