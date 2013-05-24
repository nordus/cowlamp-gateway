Schema = require('jugglingdb').Schema
mongoose = require 'mongoose'

exports.postgresql = new Schema 'postgres',
  database: 'locatemyautos_development'
  username: 'locatemyautos'
  host: 'danielnas.loginto.me'
  port: 5432
  password: 'n0rd3v'

mongoIP = process.env.IP ? 'localhost'
exports.mongoUrl = mongoUrl = switch process.env.NODE_ENV
  when 'test' then "mongodb://#{mongoIP}:27017/gateway-test"
  else process.env.MONGOHQ_URL

if process.env.NODE_ENV is 'test'
  mongoose.connect mongoUrl