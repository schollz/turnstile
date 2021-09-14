
-- definition of roman numeral chords assuming a root of C (transposable)
roman_numeral_to_chord={}
local nums={1,4,5}
local rnums={"I","IV","V"}
local notes={"C","F","G"}
local adds={"maj","maj7","min","min7"}
for i,_ in ipairs(nums) do
  roman_numeral_to_chord[nums[i]]={}
  local rn=rnums[i]
  for j,ad in ipairs(adds) do
    local rn2=rn
    if string.find(ad,"min") then
      rn2=string.lower(rn2)
    end
    if string.find(ad,"7") then
      rn2=rn2.."7"
    end
    table.insert(roman_numeral_to_chord[nums[i]],{rn=rn2,c=notes[i]..ad})
  end
end
local nums={2,3,6}
local rnums={"ii","iii","vi"}
local notes={"D","E","A"}
local adds={"min","min7","maj","maj7"}
for i,_ in ipairs(nums) do
  roman_numeral_to_chord[nums[i]]={}
  local rn=rnums[i]
  for j,ad in ipairs(adds) do
    local rn2=rn
    if string.find(ad,"min") then
      rn2=string.lower(rn2)
    else
	    rn2=string.upper(rn2)
    end
    if string.find(ad,"7") then
      rn2=rn2.."7"
    end
    table.insert(roman_numeral_to_chord[nums[i]],{rn=rn2,c=notes[i]..ad})
  end
end
local nums={7}
local rnums={"vii"}
local notes={"B"}
local adds={"dim","dim7b5"}
for i,_ in ipairs(nums) do
  roman_numeral_to_chord[nums[i]]={}
  local rn=rnums[i]
  for j,ad in ipairs(adds) do
    local rn2=rn
    if string.find(ad,"7") then
      rn2=rn2.."7"
    end
    table.insert(roman_numeral_to_chord[nums[i]],{rn=rn2,c=notes[i]..ad})
  end
end


for i,v in ipairs(roman_numeral_to_chord[7]) do
	for k,v2 in pairs(v) do
		print(i,k,v2)
	end
end
