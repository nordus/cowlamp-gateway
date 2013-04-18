rawPackets = require './raw-packets'

for packet in rawPackets
  msg = new Buffer(packet)
  decodePayload(msg)