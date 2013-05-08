postgresql = require('./db').postgresql

postgresql.on 'connected', ->
  HistoricalTrip = require '../models/historical-trip'
  
  HistoricalTrip.count {}, (err, historicalTripCount) ->
    if err
      console.error err
      
    console.log "historical_trips: #{historicalTripCount}"

#module.exports =
  #status: 0
  #device_id: '4531004944'
  #key_fob_id: 0
  #start_at: 1367358482000 / 1000
  #end_at: 1367360054000 / 1000
  #duration: 1572000
  #miles: 16.081702851000045
  #num_hard_brake: 4
  #num_hard_accel: 8
  #num_speed_event: 1
  #num_rpm_event: 4
  #ending_mileage: 1708.924971379
  #created_at: new Date()
  #updated_at: new Date()
  #start_date: new Date(1367358482000)
  #highest_speed: 79.535488
  #idle_mins: 0.08333333333333333
  #time_zone: 'America/Phoenix'
  #end_date: new Date(1367360054000)
  #qos_flags: 0
  #num_corner_l: 0
  #num_corner_r: 1
  #num_very_hard_brake: 0
  #num_very_hard_accel: 0
  #num_hard_corner_l: 0
  #num_hard_corner_r: 0
  #fuel_gal_start: 0.0
  #fuel_gal_end: 0.0

# need to remove
  # num_heading: 10,                                                                                                                                                                                                                                                                      
  # num_time_with_ignition_on: 28,                                                                                                                       