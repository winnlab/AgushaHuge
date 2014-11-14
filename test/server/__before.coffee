mongoose = require 'mongoose'

before ->

	opts =
	    server: { auto_reconnect: true, primary:null, poolSize: 50 },
	    host: 'localhost'
	    port: '27017'
	    database: 'test'
	    primary: null

	connString = 'mongodb://'+opts.host+":"+opts.port+"/"+opts.database+"?auto_reconnect=true"

	mongoose.connect connString, opts

	mongoose.connection.on 'error', (err) ->
    	console.log 'MongoDB connection error:', err