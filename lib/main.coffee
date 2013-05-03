dgram = require 'dgram'
decodePayload = require './decode-payload'
mongoose = require 'mongoose'
db = require './db'

server = dgram.createSocket 'udp4', decodePayload

server.on 'listening', ->
  mongoose.connection.on 'connected', ->
    console.log 'connected to MongoDB'
  
  mongoose.connect db.mongoUrl
  
  address = server.address()
  console.log "gateway listening on #{address.address}:#{address.port}"

server.on 'close', ->
  mongoose.connection.on 'disconnected', ->
    console.log 'disconnected from MongoDB'
  
  mongoose.disconnect()
  
  db.postgresql.disconnect()

server.bind 2013