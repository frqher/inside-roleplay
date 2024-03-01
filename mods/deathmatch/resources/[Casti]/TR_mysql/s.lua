Database = {}
Database.__index = Database

function Database:new(...)
	local instance = {}
	setmetatable(instance, Database)

	if instance:constructor(...) then
		return instance
	end
	return false
end

function Database:constructor(...)
	self.database = arg[1]
	self.host = arg[2]
	self.username = arg[3]
	self.password = arg[4]

	self.func = {}
	self.func.querryAsyncResponse = function(...) self:querryAsyncResponse(...) end
	self.func.querryAsyncMultiselectResponse = function(...) self:querryAsyncMultiselectResponse(...) end

	if self:connect() then
		return true
	else
		return false
	end
end

function Database:connect()
	-- self.connection = dbConnect("mysql", string.format("dbname=%s;host=%s;unix_socket=/var/run/mysqld/mysqld.sock", self.database, self.host), self.username, self.password, "share=1;multi_statements=1")
	self.connection = dbConnect("mysql", string.format("dbname=%s;host=%s", self.database, self.host), self.username, self.password, "share=1;multi_statements=1")
	if self.connection then
		outputDebugString(string.format("[MYSQL] Connected to the database (%s)", self.database))
		self:updateNames()
		return true
	else
		outputDebugString(string.format("[MYSQL] Cannot connect to the database (%s)", self.database), 3, 255, 0, 0)
		return false
	end
end

function Database:querry(...)
	local qh = dbQuery(self.connection, dbPrepareString(self.connection, ...))
 	if not qh then return false end
	local result, num_affected_rows, last_insert_id = dbPoll(qh, -1)
	if not result then dbFree(qh) end
	return result, num_affected_rows, last_insert_id
end

function Database:querryAsync(data, ...)
	dbQuery(self.func.querryAsyncResponse, {{data}}, self.connection, dbPrepareString(self.connection, ...))
end

function Database:querryAsyncWithoutResponse(...)
	dbQuery(function(qh) dbPoll(qh, 0) end, {}, self.connection, dbPrepareString(self.connection, ...))
end

function Database:querryAsyncResponse(qh, data)
	local result, num_affected_rows, last_insert_id = dbPoll(qh, 0)
	triggerEvent(data[1].callback, resourceRoot, data[1], result, num_affected_rows, last_insert_id)
end

function Database:querryAsyncMultiselect(data, ...)
	dbQuery(self.func.querryAsyncMultiselectResponse, {{data}}, self.connection, dbPrepareString(self.connection, ...))
end

function Database:querryAsyncMultiselectResponse(qh, data)
	local result, num_affected_rows, last_insert_id = dbPoll(qh, 0, true)
	triggerEvent(data[1].callback, resourceRoot, data[1], result, num_affected_rows, last_insert_id)
end

function Database:querryMultiselect(...)
	local qh = dbQuery(self.connection, dbPrepareString(self.connection, ...))
 	if not qh then return false end
	local result, num_affected_rows, last_insert_id = dbPoll(qh, -1, true)
	if not result then dbFree(qh) end
	return result, num_affected_rows, last_insert_id
end

function Database:updateNames()
	self:querry("SET NAMES utf8")
end




local connection
function createMysql()
	connection = Database:new("dbname", "localhost", "username", "password")
end

function querry(...)
	local querry, rows, lastID = connection:querry(...)
	return querry, rows, lastID
end

function querryMultiselect(...)
	local time = getTickCount()
	local querry, rows, lastID = connection:querryMultiselect(...)
	addDevData(getResourceName(sourceResource), getTickCount() - time, #querry)
	return querry, rows, lastID
end

function querryAsync(callback, ...)
	connection:querryAsync(callback, ...)
end

function querryAsyncMultiselect(callback, ...)
	connection:querryAsyncMultiselect(callback, ...)
end

function querryAsyncWithoutResponse(...)
	connection:querryAsyncWithoutResponse(...)
end

-- Export to dev admin data
function addDevData(resourceName, time, results)
	exports.TR_admin:addMysqlInfo(string.format("Resource: %s  Time: %d tick  Results: %d", resourceName, time, results))
end

createMysql()