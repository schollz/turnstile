-- new script v0.0.1
-- ?
--
-- llllllll.co/t/?
--
--
--
--    ▼ instructions below ▼
--
-- ?

tabutil=require("tabutil")
include("turnstile/lib/utils")
local Rings=include("turnstile/lib/Rings")
local shift=false
local is_playing
pi=3.14159265358979

mxsamples=include("mx.samples/lib/mx.samples")
engine.name="MxSamples"
skeys=mxsamples:new()

function init()
  global_time_start=current_time()
  
  -- create a list of all the known ring sets
  ringset={}
  table.insert(ringset,Rings:new())
  -- add a C-major chord
  ringset[1]:note_add(2,0,36)
  ringset[1]:note_add(1,0,40)
  ringset[1]:note_add(3,0,43)
  ringset[1]:note_add(4,0,43+12)
  -- -- add a Em/B
  ringset[1]:note_add(2,pi/2,35)
  ringset[1]:note_add(1,pi/2,40)
  ringset[1]:note_add(3,pi/2,43)
  ringset[1]:note_add(4,pi/2,43+12)
  -- add a Am/C
  ringset[1]:note_add(2,pi,36)
  ringset[1]:note_add(1,pi,40)
  ringset[1]:note_add(3,pi,45)
  ringset[1]:note_add(4,pi,45+12)
  -- -- add a F/C
  ringset[1]:note_add(1,3*pi/2,36)
  ringset[1]:note_add(2,3*pi/2,41)
  ringset[1]:note_add(3,3*pi/2,45)
  ringset[1]:note_add(4,3*pi/2,41+12)

  -- initialize metro for updating screen
  timer=metro.init()
  timer.time=1/15
  timer.count=-1
  timer.event=updater
  timer:start()
end

function updater()
  -- update each ring set
  for i,r in ipairs(ringset) do
    r:update(function(note,is_chord)
      if not is_chord then
        skeys:on({name="steinway model b",midi=note+24,velocity=math.random(40,120),sustain=0,decay=5,delay_send=0.05,amp=0.6})
      else
        -- TODO: decay should be the total lcm plus a little
        skeys:on({name="string spurs swells",midi=note,velocity=70,attack=2,sustain=0,decay=8,amp=0.7,reverb_send=0.01})
      end
    end)
  end
  redraw()
end

function toggle_playing()
  if is_playing then
    for i,r in ipairs(ringset) do
      r:stop()
    end
  else
    global_time_start=current_time()
    for i,r in ipairs(ringset) do
      r:start()
    end
  end
  is_playing = not is_playing
end

function key(k,z)
  if k==1 then
    shift=z==1
  end
  if z==0 then
    do return end
  end
  if shift then
    if k==1 then
    elseif k==2 then
    else
    end
  else
    if k==1 then
    elseif k==2 then
    elseif k==3 then
      toggle_playing()
    end
  end
end

function enc(k,d)
  if shift then
    if k==1 then
    elseif k==2 then
    else
    end
  else
    if k==1 then
    elseif k==2 then
    else
    end
  end
end

function redraw()
  screen.clear()

  -- draw the current ring set
  ringset[1]:draw()

  screen.update()
end

function rerun()
  norns.script.load(norns.state.script)
end
