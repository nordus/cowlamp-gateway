# # Message Type 2

module.exports = (msg, reading) ->
  reading.eventIndex        = msg.readUInt8(49)
  reading.eventCode         = msg.readUInt8(50)
  reading.nbrOfAccumulators = msg.readUInt8(51)
  reading.spare             = msg.readUInt8(52)
  reading.accumulator0      = msg.readUInt32BE(53)