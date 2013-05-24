#mongoose = require 'mongoose'
db = require '../lib/db'
Geofence = require '../models/geofence'
#Reading = require '../models/reading'

describe 'Geofence', ->

  beforeEach ->
#    @geofence = undefined

#    mongoose.connection.on 'connected', =>
    @geofence = new Geofence
      latitude: 33.1234
      longitude: -110.4321
      name: 'X marks the spot'
      mobileId: '453112233'

    @geofence.save (err, gf) ->
      unless err
        asyncSpecDone()

#    mongoose.connect db.mongoUrl

    asyncSpecWait()

  it 'works', ->
    expect(@geofence).toBeDefined()

#    @geofence.remove ->
#      done()

  xdescribe '.whichIntersectWith', ->
    it 'returns geofences which intersect with a point', ->
      expect(Geofence.whichIntersectWith(@dirtyDoggs.point)).toBeTruthy()

#done = ->
#  mongoose.disconnect()
#
#  db.postgresql.disconnect()