db      = require '../lib/db'
Reading = require '../models/reading'

describe 'new Reading', ->

  beforeEach ->
    @reading = new Reading
      dtcCount  : 1
      dtcCodes  : 'P0420'
      mobileId  : '9999999999'
      vBatt     : 11.00
      eventCode : 26

  it 'with dtcCount', ->
    @reading.on 'createDeviceHistory', (deviceHistory) ->

      console.log '.. createDeviceHistory detected!!!'

      expect(deviceHistory).toBeDefined()
      asyncSpecDone()

    @reading.save (err, reading) ->
      if err
        console.log err

      console.log '.. reading saved:'
      console.log reading

      expect(reading).toBeDefined()

    asyncSpecWait()