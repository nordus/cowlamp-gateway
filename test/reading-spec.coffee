Reading = require '../models/reading'
decodedMessages = require('cowlamp').decodedMessages
_ = require('underscore')._

describe 'Reading', ->
  beforeEach ->
    @message = decodedMessages['2']
    @reading = new Reading(@message)
    
  describe '#geo', ->
    it 'default type is Point', ->
      expect(@reading.geo.type).toBe 'Point'
    
    it 'coordinates contain [longitude, latitude]', ->
      differences = _.difference @reading.geo.coordinates, [@message.longitude, @message.latitude]
      expect(differences.length).toBe 0