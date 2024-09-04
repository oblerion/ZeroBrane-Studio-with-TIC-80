# Note
Recover from https://gist.github.com/oblerion/0d567a202ad6141ae2dbcecae769e281<br>
Thanks to librorumque for start it.<br>

# Install
## 1. copy packages folder to zb path
## 2. if no tic80 path are set
### default path:
- win :  "C:/Program Files (x86)/Tic80/tic80.exe"
- linux : "/usr/bin/tic80"
- macos : need to set
## 2. set path (Edit > Preferences > User config)
### on window
```lua
path.tic80 = "C:/Program Files (x86)/Tic80/tic80.exe"
```

### on linux
```lua
path.tic80 = "/usr/bin/tic80"
```
save/restart zb 

# Interpreters
- (TIC-80_LUA) run lua only
- (TIC-80_TIC) import code lua to .tic and run it

## How do you use it
- select TIC-80_LUA : Project > Lua Interpreter > TIC-80_LUA
- select TIC-80_TIC : Project > Lua Interpreter > TIC-80_TIC<br><br>
  Open your lua file and shortcut(F6) start interpreter,<br>
  (shift+F5) or (close tic80 window) for stop it.
