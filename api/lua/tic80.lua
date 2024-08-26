-- file: api/lua/tic80.lua
-- see [TIC-80 wiki](https://github.com/nesbox/TIC-80/wiki/)
--[[--
    TIC-80 API for ZBStudio
    Original writer : librorumque 2019
--]]--

local API = {
  -- Special functions
  TIC = {
    type = "function",
    description = [[Main function. It's called at 60 fps (60 times every second).]],
    args = "()",
    returns = "()"
  },
  OVR = {
    type = "function",
    description = [[Called after each frame; draw calls from this function ignore palette swap and screen offset.]],
    args = "()",
    returns = "()"
  },
  scanline = {
    type = "function",
    description = [[Called on every line render and allows you to execute some code between each line, like for scanline color trick.]],
    args = "(line)",
    returns = "()"
  },
  -- Functions
  print = {
    type = "function", 
    description = [[Print string with system font.
To use a custom rastered font, check out `font`.
To print to the console, check out `trace`.]],
    args = "(text, ?x,y=0,0, ?color=15, ?fixed=false, scale=1)",
    returns = "(text_width)"
  },
  font = {
    type = "function", 
    description = [[Print string with font defined in foreground sprites.
To simply print to the screen, check out `print`.
To print to the console, check out `trace`.]],
    args = "(text, x, y, colorkey, char_width, char_height, fixed, scale)",
    returns = "(text_width)"
  },
  clip = {
    type = "function",
    description = [[Set screen clipping region.
This function will limit what is drawn to the screen by x,y,w,h. Things drawn outside of the parameters will not be drawn to the screen.
Calling `clip()` with no parameters will reset the draw area.]],
    args = "(x, y, w, h)",
    returns = "()"
  },
  cls = {
    type = "function",
    description = [[Clear the screen.
When called this function clear all the screen using the color passed as argument. If no parameter is passed first color (0) is used.
Tips: Use a color over 15 to see some special fill pattern]],
    args = "(color)",
    returns = "()"
  },
  pix = {
    type = "function",
    description = [[Set/Get pixel color on the screen.]],
    args = "(x y ?color)",
    returns = "(color)"
  },
  line = {
    type = "function",
    description = [[Draw line. It draws a straight colored line from (x0,y0) point to (x1,y1) point.]],
    args = "(x0, y0, x1, y1, color)",
    returns = "()"
  },
  rect = {
    type = "function",
    description = [[Draw a colored filled rectangle at the specified position. 
If you need to draw only the border see `rectb`.]],
    args = "(x, y, w, h, color)",
    returns = "()"
  },
  rectb = {
    type = "function",
    description = [[Draw a rectangle border of one pixel size at the position request.
If you need to fill the rectangle with a color see `rect` instead.]],
    args = "(x, y, w, h, color)",
    returns = "()"
  },
  circ= {
    type = "function",
    description = [[Draw a filled circle with center x and y of the radius requested. It uses the bresenham algorithm.]],
    args = "(x, y, radius, color)",
    returns = "()"
  },
  circb= {
    type = "function",
    description = [[Draw a circumference with center x and y of the radius requested. It uses bresenham algorithm.]],
    args = "(x, y, radius, color)",
    returns = "()"
  },
  spr = {
    type = "function",
    description = [[Draw the sprite with given index.
You can specify a colorkey (or an array of) in the palette that will be used as transparent color. Use -1 to have an opaque sprite.
The sprite can be scaled up by a desired factor. As example: a scale of 2 means the sprite is draw in the screen as 16x16 pixel
You can flip the sprite where: 0 = No Flip; 1 = Flip horizontally; 2 = Flip vertically; 3 = Flip both vertically and horizontally.
When you rotate the sprite, it's rotated in 90° step clockwise: 0 = No rotation; 1 = 90° rotation; 2 = 180° rotation; 3 = 270° rotation]],
    args = "(spr_index, x, y, ?colorkey=-1, ?scale=1, ?flip=0, ?rotate=0, ?w,h=1,1])",
    returns = "()"
  },
  btn = {
    type = "function",
    description = [[Get gamepad button state in current frame.
This function allow to read the status of one of the buttons attached to TIC. The function return true when the key interrogated using its id, is pressed.]],
    args = "(btn_id)",
    returns = "(is_pressed)"
  },
  btnp= {
    type = "function",
    description = [[Get gamepad button state according to previous frame.
This function allow to read the status of one of the buttons attached to TIC. The function return true value only in the moment the key is pressed.
It can also be used with hold and period parameters that allow to return true keeping the key pressed. After the hold time is elapsed the function return true every time period is passed.
Time is expressed in ticks: at 60 fps it means you need to use 120 to wait 2 seconds.]],
    args = "(btn_id, ?hold,period)",
    returns = "(is_just_pressed)"
  },
  sfx = {
    type = "function",
    description = [[This function will play a sound from the sfx editor.]],
    args = "(id, ?note, ?duration=-1, ?channel=0, ?volume=15, ?speed=0)",
    returns = "()"
  },
  key = {
    type = "function",
    description = [[The function returns true if the key is pressed.]],
    args = "(key_code)",
    returns = "(is_pressed)"
  },
  keyp = {
    type = "function",
    description = [[Get gamepad button state according to previous frame.
The function return true if key is pressed in current frame and wasn't pressed in previous (same as `btnp`).]],
    args = "(key_code)",
    returns = "(is_just_pressed)"
  },
  map = {
    type = "function",
    description = [[Draw map region on the screen.
This function will draw the entire map, or parts of it. The map is measured in cells, 8x8 blocks where you can place sprites in the map editor. The map's cell limit is 240x136.
remap: function callback called before every tile drawing, you can show/hide tiles on map rendering stage (also, you can remap tile index to make map animation or even flip/rotate): callback [tile [x y] ] -> [tile [flip [rotate] ] ].]],
    args = "(?x,y=0,0 ?w,h=30,17, ?sx,sy=0,0, ?colorkey=-1, ?scale=1, ?remap=nil)",
    returns = "()"
  },
  mget = {
    type = "function",
    description = [[Get map tile index. 
Returns the sprite id at the given x and y map coordinate]],
    args = "(x, y)",
    returns = "(id)"
  },
  mset = {
    type = "function",
    description = [[Set map tile index.
This function will change the sprite in map as specified coordinates. By default, changes made are only kept while the current game is running. To make permanent changes to the map, see `sync`.]],
    args = "(x, y, id)",
    returns = "()"
  },
  music = {
    type = "function",
    description = [[Play music track by ID. It starts playing the track created in the Music Editor. Call without arguments to stop the music.]],
    args = "(?track=-1, ?frame=-1, ?row=-1, ?loop=true)",
    returns = "()"
  },
  peek = {
    type = "function",
    description = [[Read a byte value from RAM. 
This function allow to read the memory from TIC. It's useful to access resources created with the integrated tools like sprite, maps, sounds, cartridges data.
Address are in hexadecimal format but values are decimal.]],
    args = "(addr)",
    returns = "(val)"
  },
  poke = {
    type = "function",
    description = [[Write a byte value to RAM. 
        This function allows you to write to the virtual RAM of TIC. The address should be specified in hexadecimal format, and values should be given in decimal.]],
    args = "(addr)",
    returns = "(val)"
  },
  peek4 = {
    type = "function",
    description = [[Read a half byte value from RAM. 
This function allows to read the memory from TIC. Address are in hexadecimal format but values are decimal.]],
    args = "(addr4)",
    returns = "(val4)"
  },
  poke4 = {
    type = "function",
    description = [[Write a half byte value to RAM. 
This function allows you to write to the virtual RAM of TIC. It differs from `poke` in that it divides memory in groups of 4 bits. Therefore, to address the high nibble of position `0x2000` you should pass `0x4000` as addr4, and to access the low nibble (rightmost 4 bits) you would pass `0x4001`. The address should be specified in hexadecimal format, and values should be given in decimal.]],
    args = "(addr4)",
    returns = "(val4)"
  },
  reset = {
    type = "function",
    description = [[Reset game to initial state. Added in 0.60.]],
    args = "()",
    returns = "()"
  },
  memcpy = {
    type = "function",
    description = [[Copy bytes in RAM. 
This function copies a continuous block of the RAM memory of TIC to an another address. Address are in hexadecimal format, values are decimal.]],
    args = "(toaddr, fromaddr, len)",
    returns = "()"
  },
  memset = {
    type = "function",
    description = [[Set byte values in RAM.
This function allow to write a continuous block of the same value to the RAM memory of TIC. Address are in hexadecimal format, values are decimal.]],
    args = "(addr, val, len)",
    returns = "()"
  },
  pmem = {
    type = "function",
    description = [[Save integer value to persistent memory.
This function allow to save and retrieve data in one of the 256 slots available in the persistent memory. This is useful to save high-score and any sort of advancement. It reads 4 bytes(32 bit) at time. 
Tip 1: `pmem` depends of cartridge hash (md5), so don't change your lua script if you want to keep the data.
Tip 2: use saveid: with a personalized string in the header metadata to override default MD5 calculation. This allow user to update carts without losing saved state.]],
    args = "(index, ?val)",
    returns = "(val)"
  },
  trace = {
    type = "function",
    description = [[Trace string to the Console.
This is a service function useful to debug your LUA code. It will print back in the console the parameter passed.
Tip 1: LUA concatenator for string is `..`
Tip 2: Use the command cls from console to clean the output from trace.
]],
    args = "(msg, ?color)",
    returns = "()"
  },
  time = {
    type = "function",
    description = [[Returns how many ticks passed from game start. 
The function return elapsed time from the start of the cartridge expressed in milliseconds. Useful to take track of the time, animate items and raise events.]],
    args = "()",
    returns = "(milliseconds)"
  },
  mouse = {
    type = "function",
    description = [[Get coordinates and pressed state of mouse/touch. 
To use this function you need to set cartridge metadata input to mouse. Activating mouse support will turn off the gamepad.]],
    args = "()",
    returns = "(x, y, pressed)"
  },
  sync = {
    type = "function",
    description = [[Copy modified sprites/map to the cartridge. Chaged in 0.60.
Sprite and map data restores on every startup. Call `sync()` to save modified data.]],
    args = "(?mask,bank,tocart=0,0,false)",
    returns = "()"
  },
  tri = {
    type = "function",
    description = [[Draw filled triangle. 
It draws a triangle filled with color.]],
    args = "(x1, y1, x2, y2, x3, y3, color)",
    returns = "()"
  },
  textri = {
    type = "function",
    description = [[Draw triangle filled with texture.]],
    args = "(x1, y1, x2, y2, x3, y3, u1, v1, u2, v2, u3, v3, ?use_map=false, ?colorkey=-1)",
    returns = "()"
  },
  exit = {
    type = "function",
    description = [[Interrupt program and return to console at the END of the TIC function.]],
    args = "()",
    returns = "()"
  }
}


-- only copy relevant Lua functions and ones I don't know anything about
local lua = dofile("api/lua/baselib.lua")
-- @see TIC-80/luaapi.c:initLua
local included = {coroutine=true, table=true, string=true, math=true, debug=true}

for item, def in pairs(lua) do
  if included[item] then
    API[item] = def
  end
end

return API
