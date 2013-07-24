# # Message Type 10

module.exports = (msg) ->
  parsed =
    # to decimal
    latitude:   (msg.readInt32BE(17) / 10000000)
    longitude:  (msg.readInt32BE(21) / 10000000)
    heading:    msg.readUInt16BE(25)
    # cm/second to mph
    speed:      (msg.readUInt8(27) * 0.621371)
    eventCode:  msg.readUInt8(31)

  if parsed.eventCode is 25
    parsed.idleSeconds = msg.readUInt32BE(33)

  if parsed.eventCode is 26
    # millivolts to volts
    parsed.vBatt = (msg.readUInt32BE(33) * 0.001)

  if parsed.eventCode in [50, 51]
    parsed.geofenceId = msg.readUInt8(40)

  
  return parsed