dgram = require 'dgram'
decodePayload = require './decode-payload'
mongoose = require 'mongoose'

mongoUrl = process.env.MONGOHQ_URL ? 'mongodb://localhost/gateway-test'

server = dgram.createSocket 'udp4', decodePayload

server.on 'listening', ->
  mongoose.connection.on 'connected', ->
    console.log 'connected to MongoDB'
  
  mongoose.connect mongoUrl
  
  address = server.address()
  console.log "gateway listening on #{address.address}:#{address.port}"

server.on 'close', ->
  mongoose.connection.on 'disconnected', ->
    console.log 'disconnected from MongoDB'
  
  mongoose.disconnect()

server.bind 2013