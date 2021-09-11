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

I actually ended up adding three functions, one to check if a note exists, one to add it, and one to remove it. I'm not sure about the data structures (using the fractional radians as placement) but lets go with it. there are alternative datastructures (say a matrix with rows = number of rings and columns = number of places for notes), but I like a flat structure better (a list of the data).