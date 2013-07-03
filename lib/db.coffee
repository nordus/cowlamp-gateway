mongoose = require 'mongoose'

mongoIP = process.env.IP ? 'localhost'
exports.mongoUrl = mongoUrl = switch process.env.NODE_ENV
  when 'test' then "mongodb://#{mongoIP}:27017/gateway-test"
  else process.env.MONGOHQ_URL

if process.env.NODE_ENV is 'test'
  mongoose.connect mongoUrl