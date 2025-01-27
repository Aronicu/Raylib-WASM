# Raylib WASM
A Template for making Odin, Raylib, and WASM (Emscripten) projects

> [!WARNING]
> This repository is now archived, Karl Zylinksi makes a better version of the template you can find it here:
> [https://github.com/karl-zylinski/odin-raylib-web](https://github.com/karl-zylinski/odin-raylib-web)

## Features
* Works well in Windows (It probably also works for the other desktop platforms but I didn't test it)
* Logging on WASM Works!

## What won't work
* Most of Core Libraries (fmt, os, time, etc.)

## Building

### Windows
```batch
.\build.bat
```

### WASM

#### Requirements
1. [emsdk](https://emscripten.org/docs/getting_started/downloads.html)

> [!NOTE]  
> In `build_web.bat`, you need to modify the path to where your `emsdk_env.bat` is located

```batch
.\build_web.bat

:: For running
cd build_web
python -m http.server
```

## Examples
* [Breakout Clone](https://github.com/Aronicu/Breakout) - [Play it here](https://aronicu.github.io/breakout/)
* [LDTK Example](https://github.com/Aronicu/LDTK-Example) - [Play it here](https://aronicu.github.io/ldtk-example/)

## References
* [Caedo's raylib_wasm_odin](https://github.com/Caedo/raylib_wasm_odin)
* [Karl Zylinski's Odin Raylib Hot Reload Game Template](https://github.com/karl-zylinski/odin-raylib-hot-reload-game-template/)
* [Building a Web Game in C by Angus Cheng](https://anguscheng.com/post/2023-12-12-wasm-game-in-c-raylib/)
