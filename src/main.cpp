#include <iostream>

#include <SDL2/SDL.h>
#include <SDL2/SDL_syswm.h>
#include <assert.h>

#include <bx/bx.h>
#include <bgfx/bgfx.h>
#include <bgfx/platform.h>

#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#include <emscripten/html5.h>
#endif

int counter = 0;

void render_func(void) {
  bgfx::setViewClear(0, BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH, 0x443355FF, 1.0f, 0);
  bgfx::setViewRect(0, 0, 0, uint16_t(800), uint16_t(600));
  bgfx::touch(0);
  bgfx::dbgTextClear();
  bgfx::dbgTextPrintf(0, 1, 0x4f, "Counter:%d", counter++);
  bgfx::frame();
}

inline bool setupSDLWindow(SDL_Window* window) {
  SDL_SysWMinfo wmi;
  SDL_VERSION(&wmi.version);
  assert(SDL_GetWindowWMInfo(window, &wmi) == 0);

  bgfx::PlatformData pd;
#if BX_PLATFORM_LINUX || BX_PLATFORM_BSD
  pd.ndt = wmi.info.x11.display;
  pd.nwh = (void*)(uintptr_t)wmi.info.x11.window;
#elif BX_PLATFORM_OSX
  pd.ndt = NULL;
  pd.nwh = wmi.info.cocoa.window;
#elif BX_PLATFORM_WINDOWS
  pd.ndt = NULL;
  pd.nwh = wmi.info.win.window;
#elif BX_PLATFORM_STEAMLINK
  pd.ndt = wmi.info.vivante.display;
  pd.nwh = wmi.info.vivante.window;
#endif // BX_PLATFORM_
  pd.context = NULL;
  pd.backBuffer = NULL;
  pd.backBufferDS = NULL;

  bgfx::setPlatformData(pd);

  return true;
}
int main(int argc, char* argv[]) {
  assert(SDL_Init(SDL_INIT_VIDEO) == 0);

  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_ES);
  SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
  SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 32);

  SDL_Window* window = SDL_CreateWindow(
    "bgfx", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 800, 600,
    SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);

#ifdef __EMSCRIPTEN__
  SDL_GLContext glcontext = SDL_GL_CreateContext(window);
  bgfx::PlatformData pd;
  pd.context = glcontext;
  bgfx::setPlatformData(pd);
#else
  setupSDLWindow(window);
#endif

  bgfx::Init bgfxInit;
  bgfxInit.type = bgfx::RendererType::Count;
  bgfxInit.resolution.width = 800;
  bgfxInit.resolution.height = 600;
  bgfxInit.resolution.reset = BGFX_RESET_VSYNC;

  std::cout << "shit1" << std::endl;
  bgfx::init(bgfxInit);
  std::cout << "shit2" << std::endl;

#ifdef __EMSCRIPTEN__
  emscripten_set_main_loop(render_func, 60, 1);
#else
  render_func();
#endif

  SDL_DestroyWindow(window);
  SDL_Quit();
  return 0;
}

void updateApp() {
  bgfx::setViewClear(0
    , BGFX_CLEAR_COLOR|BGFX_CLEAR_DEPTH
    , 0x303030ff
    , 1.0f
    , 0
  );

  bgfx::setViewRect(0, 0, 0, uint16_t(100), uint16_t(100) );
  bgfx::touch(0);
  bgfx::dbgTextClear();

  bgfx::frame();
}
