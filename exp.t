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
require 'torch'


struct A { a : int, b : double }

C = terralib.includecstring [[
    int foo = 4;
    const int foo2 = 5;
]]


terra A:foo() 
    self.a = self.a + 1
    return self.a + self.b
end

_G.obj = terralib.new(A[1], {{3,4}})

function skoob()
  return obj[0]:foo()
end


local ffi = require("ffi")
if ffi.os == "Windows" then
  return
end

C = terralib.includecstring [[
#include <pthread.h>
#include <stdio.h>
]]

acc = global(int[4])

terra forkedFn(args : &opaque) : &opaque
  var threadid = @[&int](args)
  C.printf("threadid %d\n",threadid)
  acc[threadid] = threadid
  return nil
end

terra foo()
  var thread0 : C.pthread_t
  var thread1 : C.pthread_t
  var thread2 : C.pthread_t
  var thread3 : C.pthread_t

  acc[0]=-42
  acc[1]=-42
  acc[2]=-42
  acc[3]=-42

  var args = arrayof(int,0,1,2,3)

  C.pthread_create(&thread0,nil,forkedFn,&args[0])
  C.pthread_create(&thread1,nil,forkedFn,&args[1])
  C.pthread_create(&thread2,nil,forkedFn,&args[2])
  C.pthread_create(&thread3,nil,forkedFn,&args[3])

  C.pthread_join(thread0,nil)
  C.pthread_join(thread1,nil)
  C.pthread_join(thread2,nil)
  C.pthread_join(thread3,nil)

  return acc[0]+acc[1]+acc[2]+acc[3]
end



local MyJSONHandler = class("MyJSONHandler", turbo.web.RequestHandler)
local MyTENSORHandler = class("MyJSONHandler", turbo.web.RequestHandler)

function MyJSONHandler:get()
    self:write({ "one", "two", "three", "easy", "json", foo() })
end

function MyTENSORHandler:get()
    self:write("hello")
end

turbo.web.Application:new({
    {"^/json$", MyJSONHandler},
    {"^/t$", MyTENSORHandler}
}):listen(8888)

turbo.ioloop.instance():start()
