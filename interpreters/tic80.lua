-- file: interpreters/tic80.lua
--[[--
    TIC-80 API for ZBStudio
    @see [TIC-80 wiki](https://github.com/nesbox/TIC-80/wiki/)
--]]--
local cartext = "tic"
local srcext = "lua"


local function locateexe()
  -- TODO: look up the executable (see love2d.lua and others)
  return ide.config.path.tic80
end


local function locatecart(wfilename, args)
  local fullpath = wfilename:GetFullPath()
  
  -- Check if cart is among command line params
  if string.find(args, "[^%.%s]%." .. cartext .. "$") or
      string.find(args, "[^%.%s]%." .. cartext .. "%s") then
    return nil
  end
  
  -- Check if running a cart
  if GetFileExt(fullpath) == cartext then
    return fullpath
  end
  
  -- Look for a cart with the same name as active file.
  local guesspath
  if GetFileExt(fullpath) then
    guesspath = string.gsub(fullpath, "%.([^./\\]*)$", "." .. cartext)
  else
    guesspath = fullpath .. "." .. cartext
  end
  if wx.wxFileExists(guesspath) then
    return guesspath
  end
  
  -- Look for any cart in the same dir as the source file
  local nearest = wx.wxFindFirstFile(GetPathWithSep(wfilename) .. "*." .. cartext , wx.wxFILE)
  if wx.wxFileExists(nearest) then
    return nearest
  end
end


local function srcarg(wfilename, args)
  -- Check if something is already in command line params
  if string.find(args, "%s-code")then -- covers `-code` and `-code-watch`
    return nil
  end
  
  -- Check if the current file is source
  local active = wfilename:GetFullPath()
  if GetFileExt(active) == srcext then
    return ("-code %s"):format(active)
  end
end


-- join non-empty args with 1 space
local function command(...)
  local buf = ""
  for _, str in pairs({...}) do
    if str and str ~= "" then 
      local addspace = (#buf > 0 and string.sub(buf, -1) ~= " ")
      buf = buf .. (addspace and " " or "") .. str
    end
  end
  return buf
end


return {
  name="TIC-80",
  description="TIC-80 is a tiny computer which you can use to make, play, and share tiny games.",
  api={"tic80"},
  luaversion="5.3",
  frun=function(self,wfilename)
    local tic80 = locateexe()
    local args = self:GetCommandLineArg() or ""
    local cart = locatecart(wfilename, args)
    local code = srcarg(wfilename, args)
    
    if not tic80 then
      ide:Print("TIC-80 executable not found. Please add `path.tic80` in the config file (`Edit > Preferences`)")
    end
    
    if not cart then
      ide:Print("Using a default cart. To use an existing cart put it in the same dir as the source file, or add `/path/to/file.tic` in `Project > Command Line Parameters...`")
    end
    
    if not code then
      ide:Print("No source file specified. The code from the cart will run. To use a source file open it in the editor, or add `-code /path/to/file.lua` in `Project > Command Line Parameters...`")
    end
    
    local cmd = string.format(tic80.." "..cart.." --cmd=%cimport code %s%c",'"',code,'"') --command(tic80, cart, code, args)
    return CommandLineRun(cmd,self:fworkdir(wfilename),true,true,nil,nil,nil)
  end,
  skipcompile = true,
  hasdebugger=false,
  scratchextloop = false,
  takeparameters = true
}
