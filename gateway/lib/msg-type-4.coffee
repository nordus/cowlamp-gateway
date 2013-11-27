# # Message Type 4

module.exports = (msg, reading) ->
  reading.userMsgRoute  = msg.readUInt8(49)
  reading.userMsgId     = msg.readUInt8(50)
  reading.userMsgLength = msg.readUInt16BE(51)
  reading.userMsg       = msg.slice(53).toString('hex').toUpperCase().match(/\w{2}/g).join ' '