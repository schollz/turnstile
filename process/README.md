![image](https://raw.githubusercontent.com/schollz/turnstile/main/process/20210911-04.jpg)


# day 1 - ideas


![image](https://raw.githubusercontent.com/schollz/turnstile/main/process/20210911-01.jpg)

![image](https://raw.githubusercontent.com/schollz/turnstile/main/process/20210911-02.jpg)

![image](https://raw.githubusercontent.com/schollz/turnstile/main/process/20210911-03.jpg)


## making a skeleton

to get started with the code. I'm going to start with a skeleton of a norns script. just the basics filled out ready to fill out. here is my goto skeleton: [norns script skeleton](https://github.com/schollz/turnstile/blob/1783e943add41219ad8578010996c0291bf96ab2/turnstile.lua). it doesn't do anything, but makes space for updating screen and listening to keys / shift keys.

## making a "class" for the rings

a class is simply a mold for an object. in this script I am thinking about having different sets of rings. each set of ring should be able to pause/play. so each set should be its own object. if I code each set as a "class" then they will easily have all the same methods and internal variables, without having to worry about nesting tables.

here's more info on lua classes: https://www.lua.org/pil/16.1.html

here's the skeleton code for a class. this one happens to be called "Rings": https://github.com/schollz/turnstile/blob/122c2805ca05d506b0115416dbdae6fb529c4dc5/lib/Rings.lua

I put this into a "lib" directory and it can be accessed by the main script using a line to include it, like [here](https://github.com/schollz/turnstile/blob/f6446123ac0ed0bf661f5d7f68c73ca1bcbde15c/turnstile.lua#L12). in general it is:

```lua
-- will import "Class.lua"
local Class=include('<scriptname>/lib/Class').
```

now into what the class needs to do. I will make the class stateful - that is you can give it a time, and it will tell you the positions of the notes on its rings. it will need a function to set positions of notes, and it will need a function to get all the notes based on some time. lets add a function to add notes first. 

I actually ended up [adding three functions](https://github.com/schollz/turnstile/blob/6c6c5620628ed80deedb9a95b8dc531c81ec99a9/lib/Rings.lua#L22-L51), one to check if a note exists, one to add it, and one to remove it. I'm not sure about the data structures (using the fractional radians as placement) but lets go with it. there are alternative datastructures (say a matrix with rows = number of rings and columns = number of places for notes), but I like a flat structure better (a list of the data).

my goal right now is to right as little code as possible to get some visualization on the norns. I want to see if my math is right with the period calculations. if its all wrong, then maybe I need to change all the datastructures to better represent something that is right.

time for lunch.


## least common multiples

to get off the ground I will definetly need a function to computer the least common multiple (LCM). the algorithm is not too hard, but I just googled "lcm python" because every code snippet exists for Python and its very easy to read. [the first result](https://www.programiz.com/python-programming/examples/lcm) looks great, simple to convert to Lua. I converted it and then adjusted it so it will work with decimals. to work with decimals I just have to multiply the numbers out until they become integers and then divide by the same amount when I'm done. I then [wrote the function](https://github.com/schollz/turnstile/blob/000bc7ce2e4aa4d7571281a7cb905e65b7db80dd/lib/utils.lua) to take any number of numbers. had to lookup how to [do multiple arguments in Lua](https://stackoverflow.com/questions/48273776/vararg-function-parameters-dont-work-with-arg-variable). the way to do it is like this, using a magic variable called `arg`:

```lua
function something(...)
	local arg = {...}
	-- each argument will now be arg[1], arg[2], etc.
end
```

to integrate this into the codebase I just need to include it again with one line:

```lua
include("turnstile/lib/utils.lua")
```

all the functions in `utils.lua` are "global" so that by including them every single piece of code will have access to them.

## rings think in time, not beats

everything is going to be time based, so that you can have very irregular times. in order to do this, I need to give all the rings a notion of time. I added a `time_start` to keep track of when it is started. this will be updated when starting. so I also added the `:start()` and `:stop()` functions. getting the current time on norns is easy and precise:

```lua
function current_time()
    return clock.get_beat_sec()*clock.get_beats()
end
```

I added this to the `utils.lua`. then I added in a function to update the current positions based on time. to get things to make sound, I added a callback so that when a note crosses over the top threshold of the loop (< 0 to >=0 in math terms for the x-position) then it will call that function with the note value. I also added a function to set the period, because whenver the period is set it needs to recalculate the lcm. about [40 new lines added](https://github.com/schollz/turnstile/blob/690620fbefbc62a0cdf6f105a6bbe39b80dd1eb5/lib/Rings.lua#L26-L62).

## lets visualize

this is my favorite part. I'm going to attempt to visualize the basic routine. I'm creating a basic set of rings in the `init()` function:

```lua
-- create a list of all the known ring sets
ringset={}
table.insert(ringset,Rings:new())
-- add a C-major chord
ringset[1]:note_add(1,0,36)
ringset[1]:note_add(2,0,40)
ringset[1]:note_add(3,0,43)
```

this set of rings gets updated in the draw-routine which updates at 15 fps. that should be totally fine cpu-wise. I [also added a draw routine](https://github.com/schollz/turnstile/commit/e8113b626054e110f40ade83bc9b3331dfbd1a92) in the Rings class so that they draw themselves with one line of code (`ringset[1]:draw()`). that's nice so I don't have to write so many for loops.

**this will be the first time I'm running the program on norns now.** if it all works I will see some rings! but its 95% chance its not going to work and there will be bugs. there are always bugs. so here we go on the first bug excursions.

### bug excursion 1 - first time running on norns


so I just ssh-ed in my norns and cloned my code repository. now I'm going to open maiden so I will see all the errors that happen when I try running the code. I am going to edit the code using my desktop computer which mounted the norns drive with [SFTP Drive](https://www.nsoftware.com/sftp/drive/download.aspx).


#### bug 1 - bad logic

holy crap, I ran the code and there are no errors! ...but its clearly not showing any dots for the notes. and nothing is moving. and oh yeah, as I'm typing this I know why. I never did "start" it! so I have to code up the start, attaching it to K3.


![image](https://raw.githubusercontent.com/schollz/turnstile/main/process/first.jpg)

but that's not actually the whole problem. there should be some dots shown for the three notes. after a quick look through the code I found a bug:

```
-- if note exists do nothing
if self:note_exists(id_ring,period_fraction,note)==nil then
	do return end
end
```

whoops! the `note_exists` returns a *number* not *nil* when the note exists. thanks to my comment this was pretty easy to see. so I just need to [change this to `~=nil`](https://github.com/schollz/turnstile/commit/9be2290fa5a9366fb8b1562b81291b0d678d105a).

#### bug 2 - wrong sign in math


![image](https://raw.githubusercontent.com/schollz/turnstile/main/process/firstdots.jpg)


okay! I can see dots now! but they are on the bottom. I want the top to be the "start" position (this is arbitrary but it makes sense to me). this is just a change [of a minus sign](https://github.com/schollz/turnstile/commit/2ddfc8a9f020b58383be0c562e61e47d41b39f06).

#### bug 3 - start position is wrong

THE DOTS MOVE!!!! AND they align every 6 seconds, just like I calculated they would from the lcm (of periods of 1, 2, and 3 seconds). 

![image](https://raw.githubusercontent.com/schollz/turnstile/main/process/firstspin.gif)


another bug though, as when I start they start from some weird time. I realized I need to reset the global time counter when start is pressed. also I need to fix the start button so it actually stops too. time to move the whole routine into [its own little function](https://github.com/schollz/turnstile/commit/28ffab706574a1e0c3769868a21f13bdab5bfb28) because its big enough now.


## lets listen

my next favorite part, adding sounds in for the first time. lets go ahead and do it, even though some of the important chord pieces aren't in place. 

I'm going to use the `mx.samples` engine for this. adding it needs just a few lines to initialize:

```
mxsamples=include("mx.samples/lib/mx.samples")
engine.name="MxSamples"
skeys=mxsamples:new()
```

and then defining the callback when a note is emitted:

```
r:update(function(note)
  skeys:on({name="ghost piano",midi=note,velocity=120})
end)
```

[a small change](https://github.com/schollz/turnstile/commit/c6f88ca), but it immediately gives some audio!


## adding more chords

right now I don't have buttons to press to add notes, and it would take awhile to add them so I went ahead and just typed out chords manually.

```lua
-- add a C-major chord
ringset[1]:note_add(1,0,36)
ringset[1]:note_add(2,0,40)
ringset[1]:note_add(3,0,43)
-- add a Em/B
ringset[1]:note_add(1,pi/2,35)
ringset[1]:note_add(2,pi/2,40)
ringset[1]:note_add(3,pi/2,43)
-- add a Am/C
ringset[1]:note_add(1,pi,36)
ringset[1]:note_add(2,pi,40)
ringset[1]:note_add(3,pi,45)
```

problem though - when I start the program I don't see the notes laid out anywhere. time for another bug.

#### bug 4 - forgetting the phase

to make sure the notes start in different places they should have a different phase. I totally forgot to add phase into the calculation for the position. in `Rings.lua`, the following

```lua
self.orbit[i].x=self.radii[j] * math.sin(2*pi/self.periods[j]*time)
self.orbit[i].y=self.radii[j] * -1 * math.cos(2*pi/self.periods[j]*time)
```

should actually be

```lua
self.orbit[i].x=self.radii[j] * math.sin(2*pi/self.periods[j]*time + o.period_fraction)
self.orbit[i].y=self.radii[j] * -1 * math.cos(2*pi/self.periods[j]*time + o.period_fraction)
```

simple as that. no other math needed because I made the `period_fraction` in radians.

to switch chords I need to make sure that the phase alignment happens and changes by pi/2 radians each time. I calculated that this means each period should be changed by 1/4 * the LCM period. once [thats done](https://github.com/schollz/turnstile/commit/a0b4a6ea7f9a068ee126e86fac6bb50a2b46a301) it should work! 


https://user-images.githubusercontent.com/6550035/132969137-3a7c43fd-0dfd-4a1d-8332-3c19abd7858a.mp4


and it does!

and it kinda doesn't sound great. it sounds a little bland to me....hm.

## making it sound better

I think what I wasn't liking was that there was too much going on. I decided to distinguish between *chords* and *melody*. a *chord* is anything with the max notes. a *melody* is anything crossing the barrier as just one note. I made sure that the chords will always emit, and that the melody only emits at a certain random frequency (adjustable). I think its sounding better now. I also added a fourth ring, to fill out the chords more. that gives a better distinction between chords and melody. this is all by feel, now. I didn't like how it felt to me before and now I like it better. but there's no rhyme or reason why I just did these particular changes (4 rings instead of 3, melodies vs chords).



https://user-images.githubusercontent.com/6550035/132969136-843510df-ce19-4cb0-b4bd-41276e6e8413.mp4

and thats a good stopping point for day 1.

# day 2 - ideas

a global rate control. this might be fun to edit on the fly. global rate control should be *multiplied* by the inverse period (the rate), so it changes all the rings simultaneously. there probably needs to be a fade that allows it to fade between the new positions.

random lfos for pan/volume. like oooooo, there could be an option to randomly translate the rings and have their x position correspond to pan and the y position correspond to volume.

the callback needs to give more information. the callback should give a list of the notes and their rings. that way each ring could have its own instrument (useful for drums).

note-per-second parameter. to prevent streams of notes, there can be a random filter that prevents notes from playing. this can be set as "notes-per-second" which raises/lowers the probability of emitting a note depending on how many notes were previously emitted.

## callback

just going to do some mild refactoring here. instead of just sending the note name through the callback, I'm going to send the whole list of orbits, with all there data. then the main program and have the logic for determining how to play the notes.

## random lfos

I added in optional random lfos for amp/pan. similar to ooooo. each can be toggled on a per-ring basis. all notes on a ring share the same pan/amp. this was pretty easy coding, just a little bookkeeping.