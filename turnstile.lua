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

include("turnstile/lib/utils")
local Rings=include("turnstile/lib/Rings")
local shift=false

function init()
  global_time_start=current_time()
  
  -- create a list of all the known ring sets
  ringset={}
  table.insert(ringset,Rings:new())
  -- add a C-major chord
  ringset[1]:note_add(1,0,36)
  ringset[1]:note_add(2,0,40)
  ringset[1]:note_add(3,0,43)

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
    r:update()
  end
  redraw()
end

function key(k,z)
  if k==1 then
    shift=z==1
  end
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
