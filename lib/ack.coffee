# # Ack

dgram = require 'dgram'

# - `msg`   : buffer. raw message from the device
# - `rinfo` : object. contains `port` and `address` the message originated from
module.exports = (msg, rinfo) ->

  msg = Buffer.concat [
    # options byte, message id length, message id
    msg.slice(0, 7)
    (new Buffer([0x01, 0x01, 0x02, 0x01]))
    # sequence number
    msg.slice(11, 13)
    # message type
    msg.slice(10, 11)
    (new Buffer([0x00, 0x00, 0x00, 0x00, 0x00]))
  ]
  
  sock = dgram.createSocket 'udp4'
  # send using the same port the original message was sent to
  sock.bind 2013
  sock.send msg, 0, msg.length, rinfo.port, rinfo.address, (err, bytes) ->
    sock.close()