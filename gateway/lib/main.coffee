dgram = require 'dgram'
decodePayload = require './decode-payload'

server = dgram.createSocket 'udp4', decodePayload

server.on 'listening', ->
  address = server.address()
  console.log "gateway listening on #{address.address}:#{address.port}"


server.bind 2013