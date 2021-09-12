function lcm(...)
  local function lcm_(x,y)
    local lcm_num=0
    local greater=0

    -- choose the greater number
    if x>y then
      greater=x
    else
      greater=y
    end

    while true do
      local x_r=greater/x-math.floor(greater/x)
      local y_r=greater/y-math.floor(greater/y)
      if x_r>0.99 then
        x_r=0
      end
      if y_r>0.99 then
        y_r=0
      end
      if (x_r<0.01 and y_r<0.01) then
        lcm_num=greater
        break
      end
      greater=greater+0.01
    end

    return math.floor(lcm_num*10+0.5)/10
  end

  local res=nil
  -- https://www.lua.org/pil/5.2.html
  local arg={...}
  for i,v in ipairs(arg) do
    if i==1 then
      res=lcm_(arg[1],arg[2])
    elseif i==2 then
    else
      res=lcm_(res,v)
    end
  end
  return res
end

-- print(lcm(2,3))
-- print(lcm(1.33333,2))
-- print(lcm(1.3333,3.7,4.5))

function current_time()
  return clock.get_beat_sec()*clock.get_beats()
end
