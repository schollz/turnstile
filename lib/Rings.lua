local Rings={}

function Rings:new(o)
  -- https://www.lua.org/pil/16.1.html
  o=o or {} -- create object if user does not provide one
  setmetatable(o,self)
  self.__index=self

  -- define defaults if they are not defined
  o.num=o.num or 4
  o.radii=o.radii or {10,16,22,28}
  o.periods=o.periods or {1.5,3,2,6}
  -- run some generic initialization
  -- (useful to breakout to restart)
  o:init()
  return o
end

function Rings:init()
  -- do initialize here
  self.playing=false
  self.period_lcm=lcm(self.periods[1],self.periods[2],self.periods[3],self.periods[4])
  self.orbit={}
end

-- start simply sets playing
function Rings:start()
  self.playing=true
end

-- stop simply stops playing
function Rings:stop()
  self.playing=false
end

-- update will update all the x and y positions and 
-- if it crosses the upper side CW it will emit using a callback
function Rings:update(fn)
  -- update x and y positions
  local time=0
  if self.playing then
    time=current_time()-global_time_start
  end
  local notes_to_play={}
  for i,o in ipairs(self.orbit) do
    local j=o.id_ring
    local x_old=self.orbit[i].x
    local rate=(1/self.periods[j])
    local lcmrate=(1/self.period_lcm/4)
    rate = rate - lcmrate
    local period = 1/rate
    self.orbit[i].x=self.radii[j] * math.sin(2*pi/period*time + o.period_fraction)
    self.orbit[i].y=self.radii[j] * -1 * math.cos(2*pi/period*time + o.period_fraction)
    if self.playing and fn~=nil then
      if x_old==nil or (x_old<=0 and self.orbit[i].x>=0) then
        -- crossed over the emitter
        table.insert(notes_to_play,self.orbit[i].note)
      end
    end
  end
  if (#notes_to_play==1 and math.random()<0.2) or #notes_to_play==4 then
    for _, note in ipairs(notes_to_play) do
        fn(note,#notes_to_play==self.num)
    end
  end
end

function Rings:draw()
  screen.level(15)
  -- draw the rings
  for i=1,self.num do
    screen.circle(64,32,self.radii[i])
    screen.stroke()
  end
  -- draw the notes around each ring
  for i,o in ipairs(self.orbit) do
    -- translate to the center of the screen
    local x=o.x+64
    local y=o.y+32
    screen.circle(x,y,2)
    screen.fill()
  end
end

-- set_period will set the period and calculate the new lcm
function Rings:set_period(i,x)
  self.periods[i]=x
  self.period_lcm=lcm(self.periods[1],self.periods[2],self.periods[3],self.periods[4])
end

-- note_add adds a note to a ring
-- id_ring is the index of the ring
-- period_fraction is is the placement on the ring in radians
-- note is a midi note
function Rings:note_add(id_ring,period_fraction,note)
  -- make sure the period fraction is [0,2pi]
  period_fraction=math.fmod(period_fraction,2*pi)

  -- if note exists do nothing
  if self:note_exists(id_ring,period_fraction,note)~=nil then
    do return end
  end

  -- otherwise add it to the orbit
  table.insert(self.orbit,{id_ring=id_ring,period_fraction=period_fraction,note=note})
  self:update()
end

-- note_del deletes a note
function Rings:note_del(id_ring,period_fraction,note)
  -- if note doesn't exist do nothing
  local id=self:note_exists(id_ring,period_fraction,note)
  if id==nil then
    do return end
  end
  table.remove(self.orbit,i)
end

-- note_exists check if note exists and return its place
function Rings:note_exists(id_ring,period_fraction,note)
  for i,v in ipairs(self.orbit) do
    if v.id_ring==id_ring and v.period_fraction==period_fraction and v.note==note then
      do return i end
    end
  end
end


return Rings
