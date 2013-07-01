# # Message Type 5

module.exports = (msg) ->

  # message type 2 and 5 are same except last few bytes
  parsed = require('./common-2-and-5')(msg)
  parsed.appMessageType = msg.readUInt16BE(49)
  
  if parsed.appMessageType is 131

    # split on each null character except last
    #
    #     VIN:1G1JC5444R7252367\u0000PROTO:1\u0000
    #     #=> ['VIN:1G1JC5444R7252367', 'PROTO:1']
    "#{msg.slice(53)}".split(/\u0000(?!$)/).forEach (kv) ->
      [k, v] = kv.split ':'
      parsed[k.toLowerCase()] = v
  
  if parsed.appMessageType is 132

    parsed.dtcCount = msg.readUInt8(54)

    # ensure DTC codes (ASCII values starting at offset 55) were received
    if dtcCodes = "#{msg.slice(55)}"

      # split into 5 character DTC codes
      #
      #     P0100P0200
      #     #=> 'P0100', 'P0200'
      parsed.dtcCodes = dtcCodes.match(/[A-Z]\d{4}/g).join ', '

  return parsed