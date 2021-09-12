local Rings={}

function Rings:new(o)
  -- https://www.lua.org/pil/16.1.html
  o=o or {} -- create object if user does not provide one
  setmetatable(o,self)
  self.__index=self

  -- define defaults if they are not defined
  o.num=o.num or 4
  o.global_rate=params:get("turnstile_global_rate")
  o.radii=o.radii or {10,16,22,28}
  o.periods=o.periods or {1.5,3,2,6}
  o.pan={}
  for i=1,o.num do
    o.pan[i]={}
    o.pan[i].period=math.random(4,60)
    o.pan[i].offset=math.random(4,60)
    o.pan[i].val=0
    o.pan[i].active=false
  end
  o.amp={}
  for i=1,o.num do
    o.amp[i]={}
    o.amp[i].period=math.random(4,60)
    o.amp[i].offset=math.random(4,60)
    o.amp[i].val=0.5
    o.amp[i].active=false
  end
  -- run some generic initialization
  -- (useful to breakout to restart)
  o:init()
  return o
end

function Rings:init()
  -- do initialize here
  self.playing=false
  self.period_lcm=lcm(self.periods[1]/self.global_rate,self.periods[2]/self.global_rate,self.periods[3]/self.global_rate,self.periods[4]/self.global_rate)
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

  -- check if the global rate has changed
  if params:get("turnstile_global_rate")~=self.global_rate then
    -- fade in global rate
    self.global_rate=self.global_rate+(params:get("turnstile_global_rate")-self.global_rate)/10
    if math.abs(self.global_rate-params:get("turnstile_global_rate"))<0.2 then
      self.global_rate=params:get("turnstile_global_rate")
    end
    -- update all the periods

  end
  -- update ring pan/volume
  for i=1,self.num do
    if self.pan[i].active then
      self.pan[i].val=math.sin(2*pi/self.pan[i].period*time+self.pan[i].offset)/2
    else
      self.pan[i].val=0
    end
    if self.amp[i].active then
      self.amp[i].val=0.25+(0.25*(1+math.sin(2*pi/self.pan[i].period*time+self.pan[i].offset)))
    else
      self.amp[i].val=0.5
    end
  end

  -- update orbits
  local notes_to_play={}
  for i,o in ipairs(self.orbit) do
    local j=o.id_ring
    local x_old=self.orbit[i].x
    local rate=(self.global_rate/self.periods[j])
    local lcmrate=(1/self.period_lcm/4)
    rate=rate-lcmrate
    local period=1/rate
    self.orbit[i].x=self.radii[j]*math.sin(2*pi/period*time+o.period_fraction)
    self.orbit[i].y=self.radii[j]*-1*math.cos(2*pi/period*time+o.period_fraction)
    self.orbit[i].active=false
    self.orbit[i].pan=self.pan[o.id_ring].val
    self.orbit[i].amp=self.amp[o.id_ring].val
    if self.playing and fn~=nil then
      if x_old==nil or (x_old<=0 and self.orbit[i].x>=0) then
        -- crossed over the emitter
        table.insert(notes_to_play,self.orbit[i])
        self.orbit[i].active=true
      end
    end
  end
  if #notes_to_play>0 then
    fn(notes_to_play)
  end
end

function Rings:draw()
  screen.level(15)
  local x_center=64
  local y_center=32
  local ring_centers={}
  for i=1,self.num do
    ring_centers[i]={64,32}
    -- TODO: if LFO on
    if self.pan[i].active then
      ring_centers[i][1]=ring_centers[i][1]+util.linlin(-1,1,-63,63,self.pan[i].val)
    end
    if self.amp[i].active then
      ring_centers[i][2]=ring_centers[i][2]+util.linlin(0,1,-31,31,self.amp[i].val)
    end
  end
  -- draw the rings
  for i=1,self.num do
    screen.circle(ring_centers[i][1],ring_centers[i][2],self.radii[i])
    screen.stroke()
  end

  -- draw the notes around each ring
  for i,o in ipairs(self.orbit) do
    -- translate to the center of the screen
    local x=o.x+ring_centers[o.id_ring][1]
    local y=o.y+ring_centers[o.id_ring][2]
    screen.circle(x,y,2)
    screen.fill()
    if o.active then
      screen.circle(x,y,4)
      screen.stroke()
    end
  end
end

-- set_period will set the period and calculate the new lcm
function Rings:set_period(i,x)
  self.periods[i]=x
  self.period_lcm=lcm(self.periods[1]/self.global_rate,self.periods[2]/self.global_rate,self.periods[3]/self.global_rate,self.periods[4]/self.global_rate)
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
