mongoose = require 'mongoose'
async = require 'async'

opts =
	server: { auto_reconnect: true, primary:null, poolSize: 50 },
	user: 'admin',
	pass: 'jHn42K2p1mK',
	host: 'localhost'
	port: '27017'
	database: 'AgushaHuge'
	primary: null

connString = 'mongodb://'+opts.user+":"+opts.pass+"@"+opts.host+":"+opts.port+"/"+opts.database+"?auto_reconnect=true"

mongoose.connect connString, opts