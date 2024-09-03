local win = ide.osname == "Windows"
local mac = ide.osname == "Macintosh"
--local api = {}
--local interpreter = {}
local name = "TIC-80"

-- file: interpreters/tic80.lua
--[[--
    TIC-80 Interpreter for ZBStudio
    @see [TIC-80 wiki](https://github.com/nesbox/TIC-80/wiki/)
    Version         : 1.0
    Original writer : librorumque 2019
    Update and opti : oblerion 2024
--]]--
local function pathremover(path)
  if type(path)=="string" then
    local charfnd = string.byte("/")
    for c=path:len(),1,-1 do
      if path:byte(c) == charfnd then
        return path:sub(c+1,path:len())
      end
    end
  end
  return path
end
local interpreter_debug = {
  name=name.."_LUA",
  description="TIC-80 is a tiny computer which you can use to make, play, and share tiny games.",
  api={name},
  luaversion="5.3",
  frun=function(self,wfilename)
    local luapath = pathremover(wfilename:GetFullPath())
    local tic80 = nil--= locateexe()
    local cart = luapath:sub(1,luapath:len()-4)..".tic"
    local code = luapath
--  set or default tic80 path
    if ide.config.path.tic80~=nil then
      tic80 = ide.config.path.tic80
    elseif win then
      tic80 = "C:/Program Files (x86)/Tic80/tic80.exe"
    elseif mac then
      -- need edit by mac user
    else -- linux user
      tic80 = "/usr/bin/tic80"
    end

    if not tic80 then
      ide:Print("TIC-80 executable not found. Please add `path.tic80` in the config file (`Edit > Preferences`)")
    end
    
    if not cart then
      ide:Print("Using a default cart. To use an existing cart put it in the same dir as the source file, or add `/path/to/file.tic` in `Project > Command Line Parameters...`")
    end
    
    if not code then
      ide:Print("No source file specified. The code from the cart will run. To use a source file open it in the editor, or add `-code /path/to/file.lua` in `Project > Command Line Parameters...`")
    end
        
    local cmd = string.format("%s --skip --cmd=%sload %s & run %s",tic80,'"',code,'"')
    --string.format("%s --skip --cmd=%sload %s & import code %s & run %s",tic80,'"',cart,code,'"')
    return CommandLineRun(cmd,self:fworkdir(wfilename),true,true,nil,nil,nil)
  end,
  skipcompile = true,
  hasdebugger=false,
  scratchextloop = false,
  takeparameters = true
}
local interpreter_release = {
  name=name.."_TIC",
  description="TIC-80 is a tiny computer which you can use to make, play, and share tiny games.",
  api={name},
  luaversion="5.3",
  frun=function(self,wfilename)
    local luapath = pathremover(wfilename:GetFullPath())
    local tic80 = nil--= locateexe()
    local cart = luapath:sub(1,luapath:len()-4)..".tic"
    local code = luapath
--  set or default tic80 path
    if ide.config.path.tic80~=nil then
      tic80 = ide.config.path.tic80
    elseif win then
      tic80 = "C:/Program Files (x86)/Tic80/tic80.exe"
    elseif mac then
      -- need edit by mac user
    else -- linux user
      tic80 = "/usr/bin/tic80"
    end

    if not tic80 then
      ide:Print("TIC-80 executable not found. Please add `path.tic80` in the config file (`Edit > Preferences`)")
    end
    
    if not cart then
      ide:Print("Using a default cart. To use an existing cart put it in the same dir as the source file, or add `/path/to/file.tic` in `Project > Command Line Parameters...`")
    end
    
    if not code then
      ide:Print("No source file specified. The code from the cart will run. To use a source file open it in the editor, or add `-code /path/to/file.lua` in `Project > Command Line Parameters...`")
    end
   
    local cmd = string.format("%s --skip --cmd=%sload %s & save %s & load %s & run %s",tic80,'"',code,cart,cart,'"')
    return CommandLineRun(cmd,self:fworkdir(wfilename),true,true,nil,nil,nil)
  end,
  skipcompile = true,
  hasdebugger=false,
  scratchextloop = false,
  takeparameters = true
}
--[[--
    TIC-80 API for ZBStudio
    Original writer : librorumque 2019
    Update          : oblerion 2024
--]]--

local api = {
  BDR = {
    type = "function",
    description = [[The BDR callback allows you to execute code between the rendering of each scan line\nline = line number]],
    args = "(line:number)",
    returns = "()"
  },
  BOOT = {
    type="function",
    description = [[The BOOT function is called a single time when your cartridge is booted]],
    args = "()",
    returns = "()"
  },
  MENU = {
    type="function",
    description = [[You can define Game Menu items using the -- menu: ITEM1 ITEM2 ITEM3 metatag and handle them in the MENU(index) callback.
Note that MENU indexing starts at 0.]],
    args = "(index)",
    returns = "()"
  },
  -- Special functions
  TIC = {
    type = "function",
    description = [[Main function. It's called at 60 fps (60 times every second).]],
    args = "()",
    returns = "()"
  },
  btn = {
    type = "function",
    description = [[Get gamepad button state in current frame.
This function allow to read the status of one of the buttons attached to TIC. The function return true when the key interrogated using its id, is pressed.]],
    args = "(btn_id:number)",
    returns = "(is_pressed:bool)"
  },
  btnp= {
    type = "function",
    description = [[Get gamepad button state according to previous frame.
This function allow to read the status of one of the buttons attached to TIC. The function return true value only in the moment the key is pressed.
It can also be used with hold and period parameters that allow to return true keeping the key pressed. After the hold time is elapsed the function return true every time period is passed.
Time is expressed in ticks: at 60 fps it means you need to use 120 to wait 2 seconds.]],
    args = "(btn_id:number, ?hold,period:number)",
    returns = "(is_just_pressed:bool)"
  },
  circ= {
    type = "function",
    description = [[Draw a filled circle with center x and y of the radius requested. It uses the bresenham algorithm.]],
    args = "(x:number, y:number, radius:number, color:number)",
    returns = "()"
  },
  circb= {
    type = "function",
    description = [[Draw a circumference with center x and y of the radius requested. It uses bresenham algorithm.]],
    args = "(x:number, y:number, radius:number, color:number)",
    returns = "()"
  },
  clip = {
    type = "function",
    description = [[Set screen clipping region.
This function will limit what is drawn to the screen by x,y,w,h. Things drawn outside of the parameters will not be drawn to the screen.
Calling `clip()` with no parameters will reset the draw area.]],
    args = "(x:number, y:number, w:number, h:number)",
    returns = "()"
  },
  cls = {
    type = "function",
    description = [[Clear the screen.
When called this function clear all the screen using the color passed as argument. If no parameter is passed first color (0) is used.
Tips: Use a color over 15 to see some special fill pattern]],
    args = "(color:number)",
    returns = "()"
  },
  elli = {
    type = "function",
    description = [[This function draws a filled ellipse centered at x, y using palette index color and radius a and b. It uses the Bresenham algorithm.]],
    args = "(x:number, y:number, a:number, b:number, color:number)",
    returns = "()"
  },
  ellib = {
    type = "function",
    description = [[This function draws an ellipse border with the radiuses a b and color with its center at x, y. It uses the Bresenham algorithm.]],
    args = "(x:number, y:number, a:number, b:number, color:number)",
    returns = "()"
  },
  exit = {
    type = "function",
    description = [[Interrupt program and return to console at the END of the TIC function.]],
    args = "()",
    returns = "()"
  },
  fget = {
    type = "function",
    description = [[Returns true if the specified flag of the sprite is set.]],
    args = "(sprite_id:number, flag:number)",
    returns = "(r:bool)"    
  },
  fset = {
    type = "function",
    description = [[This function sets the sprite flag to a given boolean value.]],
    args = "(sprite_id:number, flag:number, state:bool)",
    returns = "()"    
  },
  font = {
    type = "function", 
    description = [[Print string with font defined in foreground sprites.
To simply print to the screen, check out `print`.
To print to the console, check out `trace`.]],
    args = "(text:string, x:number, y:number, ?colorkey:number, ?char_width:number, ?char_height:number, ?fixed=false, ?scale=1, ?alf=false)",
    returns = "(text_width:number)"
  },
  key = {
    type = "function",
    description = [[The function returns true if the key is pressed.]],
    args = "(key_code:number)",
    returns = "(is_pressed:bool)"
  },
  keyp = {
    type = "function",
    description = [[Get gamepad button state according to previous frame.
The function return true if key is pressed in current frame and wasn't pressed in previous (same as `btnp`).]],
    args = "(key_code:number)",
    returns = "(is_just_pressed:bool)"
  },
  line = {
    type = "function",
    description = [[Draw line. It draws a straight colored line from (x0,y0) point to (x1,y1) point.]],
    args = "(x0:number, y0:number, x1:number, y1:number, color:number)",
    returns = "()"
  },
  map = {
    type = "function",
    description = [[Draw map region on the screen.
This function will draw the entire map, or parts of it. The map is measured in cells, 8x8 blocks where you can place sprites in the map editor. The map's cell limit is 240x136.
remap: function callback called before every tile drawing, you can show/hide tiles on map rendering stage (also, you can remap tile index to make map animation or even flip/rotate): callback [tile [x y] ] -> [tile [flip [rotate] ] ].]],
    args = "(?x=0, ?y=0, ?w=30, ?h=17, ?sx=0, ?sy=0, ?colorkey=-1, ?scale=1, ?remap=nil)",
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
  mget = {
    type = "function",
    description = [[Get map tile index. 
Returns the sprite id at the given x and y map coordinate]],
    args = "(x:number, y:number)",
    returns = "(id:number)"
  },
  mset = {
    type = "function",
    description = [[Set map tile index.
This function will change the sprite in map as specified coordinates. By default, changes made are only kept while the current game is running. To make permanent changes to the map, see `sync`.]],
    args = "(x:number, y:number, id:number)",
    returns = "()"
  },
  mouse = {
    type = "function",
    description = [[This function returns the mouse coordinates, a boolean value for the state of each mouse button (with true indicating that a button is pressed) and any change in the scroll wheel. Note that scrollx values are only returned for devices with a second scroll wheel, trackball etc.]],
    args = "()",
    returns = "(x:number, y:number, left:bool, middle:bool, right:bool, scrollx:number, scrolly:number)"
  },
  music = {
    type = "function",
    description = [[Play music track by ID. It starts playing the track created in the Music Editor. Call without arguments to stop the music.]],
    args = "(?track=-1, ?frame=-1, ?row=-1, ?loop=true, ?sustain=false, ?tempo=-1, ?speed=-1)",
    returns = "()"
  },
  peek = {
    type = "function",
    description = [[This function allows you to read directly from RAM. It can be used to access resources created with the integrated tools, such as the sprite, map and sound editors, as well as cartridge data.

The requested number of bits is read from the address requested. The address is typically specified in hexadecimal format.]],
    args = "(addr:hexa, ?bits=8)",
    returns = "(val)"
  },
  peek4 = {
    type = "function",
    description = [[This function allows you to read directly from RAM. It can be used to access resources created with the integrated tools, such as the sprite, map and sound editors, as well as cartridge data.

The requested number of bits is read from the address requested. The address is typically specified in hexadecimal format.]],
    args = "(addr:hexa)",
    returns = "(val)"
  },
  peek2 = {
    type = "function",
    description = [[This function allows you to read directly from RAM. It can be used to access resources created with the integrated tools, such as the sprite, map and sound editors, as well as cartridge data.

The requested number of bits is read from the address requested. The address is typically specified in hexadecimal format.]],
    args = "(addr:hexa)",
    returns = "(val)"
  },
  peek1 = {
    type = "function",
    description = [[This function allows you to read directly from RAM. It can be used to access resources created with the integrated tools, such as the sprite, map and sound editors, as well as cartridge data.

The requested number of bits is read from the address requested. The address is typically specified in hexadecimal format.]],
    args = "(addr:hexa)",
    returns = "(val)"
  },
  pix = {
    type = "function",
    description = [[Set/Get pixel color on the screen.]],
    args = "(x:number, y:number, ?color:number)",
    returns = "(color)"
  },
  pmem = {
    type = "function",
    description = [[Save integer value to persistent memory.
This function allow to save and retrieve data in one of the 256 slots available in the persistent memory. This is useful to save high-score and any sort of advancement. It reads 4 bytes(32 bit) at time. 
Tip 1: `pmem` depends of cartridge hash (md5), so don't change your lua script if you want to keep the data.
Tip 2: use saveid: with a personalized string in the header metadata to override default MD5 calculation. This allow user to update carts without losing saved state.]],
    args = "(index:number, ?val:number)",
    returns = "(val:number)"
  },
  poke = {
    type = "function",
    description = [[Write a byte value to RAM. 
        This function allows you to write to the virtual RAM of TIC. The address should be specified in hexadecimal format, and values should be given in decimal.]],
    args = "(addr:hexa, val:number, ?bits=8)",
    returns = "()"
  },
  poke4 = {
    type = "function",
    description = [[Write a half byte value to RAM. 
This function allows you to write to the virtual RAM of TIC. It differs from `poke` in that it divides memory in groups of 4 bits. Therefore, to address the high nibble of position `0x2000` you should pass `0x4000` as addr4, and to access the low nibble (rightmost 4 bits) you would pass `0x4001`. The address should be specified in hexadecimal format, and values should be given in decimal.]],
    args = "(addr4:hexa)",
    returns = "(val4:number)"
  },
  print = {
    type = "function", 
    description = [[Print string with system font.
To use a custom rastered font, check out `font`.
To print to the console, check out `trace`.]],
    args = "(text:string, ?x,y=0,0, ?color=15, ?fixed=false, ?scale=1)",
    returns = "(text_width:number)"
  },
  rect = {
    type = "function",
    description = [[Draw a colored filled rectangle at the specified position. 
If you need to draw only the border see `rectb`.]],
    args = "(x:number, y:number, w:number, h:number, color:number)",
    returns = "()"
  },
  rectb = {
    type = "function",
    description = [[Draw a rectangle border of one pixel size at the position request.
If you need to fill the rectangle with a color see `rect` instead.]],
    args = "(x:number, y:number, w:number, h:number, color:number)",
    returns = "()"
  },
  reset = {
    type = "function",
    description = [[Resets the TIC virtual "hardware" and immediately restarts the cartridge.]],
    args = "()",
    returns = "()"
  },
  sfx = {
    type = "function",
    description = [[This function will play a sound from the sfx editor.]],
    args = "(id:number, ?note=-1, ?duration=-1, ?channel=0, ?volume=15, ?speed=0)",
    returns = "()"
  },
  spr = {
    type = "function",
    description = [[Draw the sprite with given index.
You can specify a colorkey (or an array of) in the palette that will be used as transparent color. Use -1 to have an opaque sprite.
The sprite can be scaled up by a desired factor. As example: a scale of 2 means the sprite is draw in the screen as 16x16 pixel
You can flip the sprite where: 0 = No Flip; 1 = Flip horizontally; 2 = Flip vertically; 3 = Flip both vertically and horizontally.
When you rotate the sprite, it's rotated in 90° step clockwise: 0 = No rotation; 1 = 90° rotation; 2 = 180° rotation; 3 = 270° rotation]],
    args = "(spr_index:number, x:number, y:number, ?colorkey=-1, ?scale=1, ?flip=0, ?rotate=0, ?w=1, ?h=1])",
    returns = "()"
  },
  sync = {
    type = "function",
    description = [[Use sync() to save data you modify during runtime and would like to persist, or to restore runtime data from the cartridge.\nmask : tiles=1 sprites=2 map=4 sfx=8 music=16 palette=32 flags=64 screen=128\nbank : 0 -> 7]],
    args = "(?mask=0, ?bank=0, ?tocart=false)",
    returns = "()"
  },
  ttri = {
    type = "function",
    description = [[This function draws a triangle filled with texture from either SPRITES or MAP RAM or VBANK.]],
    args = "(x1:number, y1:number, x2:number, y2:number, x3:number, y3:number, u1:number, v1:number, u2:number, v2:number, u3:number, v3:number, ?texsrc=0, ?chromakey=-1, ?z1=0, ?z2=0, ?z3=0)",
    returns = "()"
  },
  time = {
    type = "function",
    description = [[Returns how many ticks passed from game start. 
The function return elapsed time from the start of the cartridge expressed in milliseconds. Useful to take track of the time, animate items and raise events.]],
    args = "()",
    returns = "(milliseconds:number)"
  },
  trace = {
    type = "function",
    description = [[Trace string to the Console.
This is a service function useful to debug your LUA code. It will print back in the console the parameter passed.
Tip 1: LUA concatenator for string is `..`
Tip 2: Use the command cls from console to clean the output from trace.
]],
    args = "(message:string, ?color=15)",
    returns = "()"
  },
  tri = {
    type = "function",
    description = [[Draw filled triangle. 
It draws a triangle filled with color.]],
    args = "(x1:number, y1:number, x2:number, y2:number, x3:number, y3:number, color:number)",
    returns = "()"
  },
  trib = {
    type = "function",
    description = [[This function draws a triangle border with color, using the supplied vertices.]],
    args = "(x1:number, y1:number, x2:number, y2:number, x3:number, y3:number, color:number)",
    returns = "()"
  },
  tstamp = {
    type = "function",
    description = [[This function returns the number of seconds elapsed since January 1st, 1970. This can be quite useful for creating persistent games which evolve over time between plays.]],
    args = "()",
    returns = "(timestamp:number)"
  },
  vbank = {
    type = "function",
    description = [[VRAM is double-banked, such that the entire 16kb VRAM address space can be "swapped" at any time between banks 0 and 1. This is most commonly used for layering effects (background vs foreground layers, or a HUD that sits overtop of your main gameplay area, etc).]],
    args = "(id:number)",
    returns = "()"
  }
}
-- only copy relevant Lua functions and ones I don't know anything about
local lua = dofile("api/lua/baselib.lua")
-- @see TIC-80/luaapi.c:initLua
local included = {coroutine=true, table=true, string=true, math=true, debug=true}

for item, def in pairs(lua) do
  if included[item] then
    api[item] = def
  end
end

-- package TIC-80
return {
  name = name,
  description = "Implements integration with TIC80.",
  author = "librorumque, oblerion, atesin",
  version = 0.1,
  onRegister = function(self)
    ide:AddInterpreter(interpreter_debug.name, interpreter_debug)
    ide:AddInterpreter(interpreter_release.name, interpreter_release)
    ide:AddAPI("lua", name, api)
  end,
  onUnRegister = function(self)
    ide:RemoveInterpreter(interpreter_debug.name, interpreter_debug)
    ide:RemoveInterpreter(interpreter_release.name, interpreter_release)
    ide:RemoveAPI("lua", name)
  end,
}

