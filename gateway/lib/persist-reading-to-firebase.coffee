request = require 'request'


module.exports = (reading) ->
  request.post "https://homeclub-gateway.firebaseIO.com/readings/#{reading.mobileId}.json?auth=8HE3aL3hzrWia4jMHXYhh05xkP9ZVqmHFt2wHDha",
    form: reading