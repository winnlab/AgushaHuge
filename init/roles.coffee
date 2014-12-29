async = require 'async'
roles = require 'roles'
_ = require 'underscore'

Role = require '../models/role'
Permission = require '../models/permission'

exports.init = (callback) ->
	async.parallel
		roles: (next2) ->
			Role.find().populate('permissions').exec next2
		permissions: (next2) ->
			Permission.find next2
	, (err, results) ->
		if err
			console.log err
			return false
			
		appName = 'agusha'
		
		permissions = _.pluck results.permissions, 'name'
		
		rolesApp = roles.addApplication appName, permissions
		
		i = results.roles.length
		while i--
			perms = []
			j = results.roles[i].permissions.length
			while j--
				perms.push appName + '.' + results.roles[i].permissions[j].name
			
			console.log results.roles[i].name, perms
			
			roles.addProfile results.roles[i].name, perms
		
		callback null