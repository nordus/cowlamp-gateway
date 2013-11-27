# # Ack

dgram = require 'dgram'

# - `msg`   : buffer. raw message from the device
# - `rinfo` : object. contains `port` and `address` the message originated from
module.exports = (msg, rinfo) ->

  msg = Buffer.concat [
    (msg.slice(0, 7))
    (new Buffer([0x01, 0x01, 0x02, 0x01]))
    (msg.slice(11, 13))
    (msg.slice(10, 11))
    (new Buffer([0x00, 0x00, 0x00, 0x00, 0x00]))
  ]

  sock = dgram.createSocket 'udp4'
  sock.bind 2013
  sock.send msg, 0, msg.length, rinfo.port, rinfo.address, (err, bytes) ->
    sock.close()