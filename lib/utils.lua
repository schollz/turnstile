function lcm(...)
    local function lcm_(x, y)
       local lcm_num=0
       local greater=0
       local multiplier=1
       while math.floor(x)~=x or math.floor(y)~=y do
        x=x*10
        y=y*10
        multiplier=multiplier*10
       end

       -- choose the greater number
       if x > y then
           greater = x
       else
           greater = y
       end

       while true do
           if ((greater % x == 0) and (greater % y == 0)) then
               lcm_num = greater
               break
           end
           greater = greater + 1
       end

       return lcm_num/multiplier
    end

    local res=nil
    -- https://www.lua.org/pil/5.2.html
    local arg = {...}
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


function current_time()
    return clock.get_beat_sec()*clock.get_beats()
end