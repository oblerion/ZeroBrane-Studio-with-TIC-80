-- file: interpreters/tic80.lua
--[[--
    TIC-80 Interpreter for ZBStudio
    @see [TIC-80 wiki](https://github.com/nesbox/TIC-80/wiki/)
    Version         : 1.0
    Original writer : librorumque 2019
    Update and opti : oblerion 2024
--]]--
local win = ide.osname == "Windows"
local mac = ide.osname == "Macintosh"
local cartext = "tic"
local srcext = "lua"


local function locateexe()
  local lpath
  if ide.config.path.tic80~=nil then
    lpath = ide.config.path.tic80
  elseif win then
    lpath = "C:/Program Files (x86)/Tic80/tic80.exe"
  elseif mac then
    -- need edit by mac user
  else -- linux user
    lpath = "/usr/bin/tic80"
  end
  return lpath
end


local function locatecart(wfilename)--, args)
  local fullpath = wfilename:GetFullPath()
  local scart=fullpath:sub(1,fullpath:len()-3)..".tic"
-- reverse search of .
 -- for i=fullpath:len(),1,-1 do
 --   if fullpath[i]=='.' then
    -- remove 3 char and add .tic
      --scart = path1..".tic"
      --break
    --end
  --end
  return scart
end


return {
  name="TIC-80",
  description="TIC-80 is a tiny computer which you can use to make, play, and share tiny games.",
  api={"tic80"},
  luaversion="5.3",
  frun=function(self,wfilename)
    local tic80 = locateexe()
    local cart = locatecart(wfilename)
    local code = wfilename:GetFullPath()
    
    if not tic80 then
      ide:Print("TIC-80 executable not found. Please add `path.tic80` in the config file (`Edit > Preferences`)")
    end
    
    if not cart then
      ide:Print("Using a default cart. To use an existing cart put it in the same dir as the source file, or add `/path/to/file.tic` in `Project > Command Line Parameters...`")
    end
    
    if not code then
      ide:Print("No source file specified. The code from the cart will run. To use a source file open it in the editor, or add `-code /path/to/file.lua` in `Project > Command Line Parameters...`")
    end
        
    local cmd = string.format(tic80.." "..cart.." --cmd="..'"'.."import code %s"..'"',code)
    return CommandLineRun(cmd,self:fworkdir(wfilename),true,true,nil,nil,nil)
  end,
  skipcompile = true,
  hasdebugger=false,
  scratchextloop = false,
  takeparameters = true
}
