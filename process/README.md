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

