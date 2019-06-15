# bgfx build test

This is my ~~failed~~ *work in progress* attempt at building and initializing bgfx using emscripten and WebGL.

To use, just clone and run `make`. If everything works, all of the submodule dependencies should be cloned, emscripten should initialize, and everything will build.

Check the Emscripten docs for common dependencies on your platform.
Tested fine on Windows, but you'll need to run it from a bash terminal and have MinGW in your PATH var.