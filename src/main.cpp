#include <iostream>

#include <stdio.h>

#include <bx/bx.h>
#include <bgfx/bgfx.h>
#include <bgfx/platform.h>

#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#include <emscripten/html5.h>
#endif


extern "C" void updateApp() {
  bgfx::setViewClear(0
    , BGFX_CLEAR_COLOR|BGFX_CLEAR_DEPTH
    , 0x303030ff
    , 1.0f
    , 0
  );

  bgfx::setViewRect(0, 0, 0, uint16_t(100), uint16_t(100) );
  bgfx::touch(0);
  bgfx::dbgTextClear();

  /* const bgfx::Stats* stats = bgfx::getStats();
			bgfx::dbgTextPrintf(0, 2, 0x0f, "Backbuffer %dW x %dH in pixels, debug text %dW x %dH in characters."
				, stats->width
				, stats->height
				, stats->textWidth
				, stats->textHeight
  );*/

  // Advance to next frame. Rendering thread will be kicked to
  // process submitted rendering primitives.
  bgfx::frame();
}

extern "C" int main(int argc, char** argv) {
  std::cout << "Hello, World!" << std::endl;

  //bgfx::renderFrame();

  bgfx::Init init;
  init.resolution.width = 800;
  init.resolution.height = 600;

  if (!bgfx::init(init))
    return 1;

  emscripten_set_main_loop(&updateApp, -1, 1);

  return 0;
}
