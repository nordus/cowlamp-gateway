module.exports = (msg) -> {
  # to decimal
  latitude:   (msg.readInt32BE(21) / 10000000)
  longitude:  (msg.readInt32BE(25) / 10000000)
  # cm to ft
  altitude:   (msg.readInt32BE(29) * 0.0328084)
  # cm/second to mph
  speed:      (msg.readUInt32BE(33) * 0.022369362920544023)
  heading:    msg.readUInt16BE(37)
  satellites: msg.readUInt8(39)
  rssi:       msg.readInt16BE(43)
  # to units of 0.1
  hdop:       (msg.readUInt8(46) / 10)
}