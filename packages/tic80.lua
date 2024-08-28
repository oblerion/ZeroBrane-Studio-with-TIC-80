local win = ide.osname == "Windows"
local mac = ide.osname == "Macintosh"

-- file: interpreters/tic80.lua
--[[--
    TIC-80 Interpreter for ZBStudio
    @see [TIC-80 wiki](https://github.com/nesbox/TIC-80/wiki/)
    Version         : 1.0
    Original writer : librorumque 2019
    Update and opti : oblerion 2024
--]]--
local interpreter = {
  name="TIC-80",
  description="TIC-80 is a tiny computer which you can use to make, play, and share tiny games.",
  api={"tic80"},
  luaversion="5.3",
  frun=function(self,wfilename)
    local luapath = wfilename:GetFullPath()
    local tic80 = nil--= locateexe()
    local cart = luapath:GetFullPath():sub(1,luapath:len()-4)..".tic"
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
        
    local cmd = string.format(tic80.." "..cart.." --cmd="..'"'.."import code %s"..'"',code)
    return CommandLineRun(cmd,self:fworkdir(wfilename),true,true,nil,nil,nil)
  end,
  skipcompile = true,
  hasdebugger=false,
  scratchextloop = false,
  takeparameters = true
}
-- package TIC-80
local name = 'TIC-80'
return {
  name = "TIC-80",
  description = "Implements integration with TIC80.",
  author = "librorumque, oblerion, atesin",
  version = 0.01,

  onRegister = function(self)
    ide:AddInterpreter(name, interpreter)
    --ide:AddSpec(name, spec)
  end,
  onUnRegister = function(self)
    ide:RemoveInterpreter(name)
    --ide:RemoveSpec(name)
  end,
}
