-- new script v0.0.1
-- ?
--
-- llllllll.co/t/turnstile
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

mxsamples=include("mx.samples/lib/mx.samples")
engine.name="MxSamples"
skeys=mxsamples:new()

function init()
  global_time_start=current_time()

  -- setup parameters
  params:add_control("turnstile_global_rate","global rate",controlspec.new(0.25,10,'lin',0.25,1.0,'x',0.25/10))

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
  ringset[1].notes_per_second={}

  -- initialize metro for updating screen
  timer=metro.init()
  timer.time=1/30
  timer.count=-1
  timer.event=updater
  timer:start()
  timer2=metro.init()
  timer2.time=1/15
  timer2.count=-1
  timer2.event=redrawer
  timer2:start()
  

  ring_play=1
  ring_play_count=0
  ring_play_count_next=4
end

function redrawer()
  redraw()
end

function updater()
  -- update each ring set
  local ct=current_time()
  for i,r in ipairs(ringset) do
    -- clear the current notes per second
    local new_notes_per_second={}
    for i,t in ipairs(r.notes_per_second) do
      if ct-t>0 and ct-t<10 then
        -- keep it
        table.insert(new_notes_per_second,t)
      end
    end
    -- update the notes
    ringset[i].notes_per_second=new_notes_per_second
    -- determine the actual number
    local notes_per_second=#ringset[i].notes_per_second/10
    local nps_target=util.linlin(-1,1,0,10,math.sin(2*pi/30*ct))
    local ring_last=1
    r:update(function(orbits)
      if #orbits==4 then
        print("chord: "..ct-global_time_start)
        for _,o in ipairs(orbits) do
          -- decay should correspond to the tempo
          local decay=clock.get_beat_sec()*8*1.5
          skeys:on({name="string spurs swells",midi=o.note,pan=o.pan,velocity=70,attack=2,sustain=0,decay=decay,amp=0.5,reverb_send=0.02})
        end
end
if true then
	local rp=ring_play
        for _,o in ipairs(orbits) do
          if rp==o.id_ring then
            skeys:on({name="ghost piano",midi=o.note+24,pan=o.pan,velocity=math.random(60,120),sustain=0,decay=5,delay_send=0.00,amp=0.6})
            if ring_play_count>ring_play_count_next then
              ring_play=math.random(1,4)
              ring_play_count=0
	      ring_play_count_next=math.random(1,8)
            end
            ring_play_count=ring_play_count+1
          end

        end
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
  is_playing=not is_playing
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

  -- show the current bpm
  screen.move(1,8)
  screen.text(string.format("bpm: %2.1f",16/ringset[1].period_lcm*60))

  screen.update()
end

function rerun()
  norns.script.load(norns.state.script)
end
