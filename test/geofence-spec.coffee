Geofence = require '../models/geofence'

xdescribe 'Geofence', ->
  describe '.whichIntersectWith', ->
    it 'returns geofences which intersect with a point', ->
      expect(Geofence.whichIntersectWith(@dirtyDoggs.point)).toBeTruthy()