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
  self.orbit={}
end

-- note_add adds a note to a ring
-- ring_id is the index of the ring
-- period_fraction is is the placement on the ring in radians
-- note is a midi note
function Rings:note_add(ring_id,period_fraction,note)
  -- if note exists do nothing
  if self:note_exists(ring_id,period_fraction,note)==nil then
    do return end
  end
  -- otherwise add it to the orbit
  table.insert(self.orbit,{ring_id=ring_id,period_fraction=period_fraction,note=note})
end

function Rings:note_del(ring_id,period_fraction,note)
  -- if note doesn't exist do nothing
  local id=self:note_exists(ring_id,period_fraction,note)
  if id==nil then
    do return end
  end
  table.remove(self.orbit,i)
end

-- note_exists check if note exists and return its place
function Rungs:note_exists(ring_id,period_fraction,note)
  for i,v in ipairs(self.orbit) do
    if v.ring_id==ring_id and v.period_fraction==period_fraction and v.note==note then
      do return i end
    end
  end
end

return Rings
