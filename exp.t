_G.io_loop_instance = nil
_G.rc = nil
_G.r = nil
_G.TURBO_STATIC_MAX = nil
_G.TURBO_SOCKET_BUFFER_SZ = nil
_G.SIGCHLD = nil
_G.SIGIO = nil
_G.__TURBO_USE_LUASOCKET__ = false
_G.TURBO_SSL = false
local turbo = require "turbo"


C = terralib.includecstring [[
    int foo = 4;
    const int foo2 = 5;
]]
terra t()
    C.foo = C.foo + 1;
    return C.foo + C.foo2
end

local MyJSONHandler = class("MyJSONHandler", turbo.web.RequestHandler)
function MyJSONHandler:get()
    self:write({ "one", "two", "three", "easy", "json", t() })
end

turbo.web.Application:new({
    {"^/json$", MyJSONHandler}
}):listen(8888)

turbo.ioloop.instance():start()
