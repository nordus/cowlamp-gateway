# # Ack

dgram = require 'dgram'

# - `msg`   : buffer. raw message from the device
# - `rinfo` : object. contains `port` and `address` the message originated from
module.exports = (msg, rinfo) ->

  msg = Buffer.concat [
    # 0 is the mobile ID length
    # 1-6 are mobile ID
    (msg.slice(0, 7))
    
    # hardcoded param as per Calamp docs
    (new Buffer([0x01, 0x01, 0x02, 0x01]))
    
    # 11-12 are sequence number
    (msg.slice(11, 13))
    
    # 10 is msg type
    (msg.slice(10, 11))
    
    # hardcoded param as per Calamp docs
    (new Buffer([0x00, 0x00, 0x00, 0x00, 0x00]))
  ]

  sock = dgram.createSocket 'udp4'
  sock.bind 2013
  sock.send msg, 0, msg.length, rinfo.port, rinfo.address, (err, bytes) ->
    sock.close()
