local Rings={}

function Rings:new(o)
  -- https://www.lua.org/pil/16.1.html
  o=o or {} -- create object if user does not provide one
  setmetatable(o,self)
  self.__index=self

  -- define defaults if they are not defined
  o.num=o.num or 3
  -- run some generic initialization
  -- (useful to breakout to restart)
  o:init()
  return o
end

function Rings:init()
  -- do initialize here
end

return Rings
