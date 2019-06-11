TARGET?=Debug

EMSCRIPTEN := deps/emsdk/fastcomp/emscripten
EMSCRIPTEN_ABS :=$(addprefix ${CURDIR}/, $(EMSCRIPTEN))
EMSDK := deps/emsdk/emsdk
CXX := $(EMSCRIPTEN)/em++

SRC_PATH := src
BUILD_PATH := build
OBJ_PATH := $(BUILD_PATH)/obj
INCLUDE_PATH := $(BUILD_PATH)/include
RELEASE_PATH := $(BUILD_PATH)/bin

INCLUDE_FILE_CHECK := $(INCLUDE_PATH)/SDL2/SDL.h
CXX_FILE_CHECK := $(CXX)

CXXFLAGS := -std=c++11 -Wall -Ideps/bx/include -Ideps/bgfx/include -I$(INCLUDE_PATH) -s USE_SDL=2 -s USE_WEBGL2=1 -s FULL_ES3=1 -s ALLOW_MEMORY_GROWTH=1
LINKFLAGS := -s USE_SDL=2 -s USE_WEBGL2=1 -s FULL_ES3=1 -s ALLOW_MEMORY_GROWTH=1

ifeq ($(TARGET), Debug)
$(info ===== Build mode set to TARGET=Debug =====)
CXXFLAGS += -g4 -v -s ASSERTIONS=2 -s SAFE_HEAP=1 -s STACK_OVERFLOW_CHECK=2
LINKFLAGS += -v -s ASSERTIONS=2 -s SAFE_HEAP=1 -s STACK_OVERFLOW_CHECK=2
else
TARGET = Release
$(info ===== Build mode set to TARGET=Release =====)
CXXFLAGS += -g0 -O3
endif

SRC_FILES := $(wildcard $(SRC_PATH)/*.cpp)
OBJ_FILES := $(patsubst $(SRC_PATH)/%.cpp,$(OBJ_PATH)/%.bc,$(SRC_FILES))

BGFX_LIBS_PATH := deps/bgfx/.build/asmjs/bin
BGFX_LIB_NAMES := libbgfx$(TARGET).a libbimg_decode$(TARGET).a libbimg$(TARGET).a libbx$(TARGET).a
BGFX_LIBS := $(addprefix $(BGFX_LIBS_PATH)/, $(BGFX_LIB_NAMES))
OBJ_FILES += $(BGFX_LIBS)

default: build

.PHONY: build
build: $(RELEASE_PATH)/out.html

$(RELEASE_PATH)/out.html: $(OBJ_FILES)
	$(info ===== Linking $@ =====)
	@mkdir -p $(RELEASE_PATH)
	"$(CXX)" $(LINKFLAGS) -o $@ $^

$(OBJ_PATH)/%.bc: $(SRC_PATH)/%.cpp $(CXX_FILE_CHECK) $(INCLUDE_FILE_CHECK)
	$(info ===== Compiling $< =====)
	@mkdir -p $(OBJ_PATH)
	"$(CXX)" $(CXXFLAGS) -c -o $@ $<

$(BGFX_LIBS_PATH)/%Release.a:
	EMSCRIPTEN=$(EMSCRIPTEN_ABS) make -C deps/bgfx asmjs-release

$(BGFX_LIBS_PATH)/%Debug.a:
	EMSCRIPTEN=$(EMSCRIPTEN_ABS) EMCC_DEBUG=1 ASSERTIONS=2 SAFE_HEAP=1 STACK_OVERFLOW_CHECK=2 make -C deps/bgfx asmjs-debug

.PHONY: bgfx
bgfx:
	$(call $(word 1, $(BGFX_LIBS)))

$(CXX_FILE_CHECK): $(EMSDK)
	# cd deps/emsdk && ./emsdk install sdk-incoming-64bit
	# cd deps/emsdk && ./emsdk activate sdk-incoming-64bit
	cd deps/emsdk && ./emsdk install latest
	$(call patch_emscripten)

$(INCLUDE_FILE_CHECK): $(EMSDK)
	mkdir -p $(INCLUDE_PATH)/SDL2
	cp deps/emscripten_ports/SDL2/include/* $(INCLUDE_PATH)/SDL2

$(EMSDK):
	$(call submodules)

.PHONY: submodules
submodules:
	git submodule update --init --recursive

.PHONY: patch_emscripten
patch_emscripten:
	find ./deps/emsdk/fastcomp/emscripten/src -type f -exec sed -i 's/glGetInternalFormativ/glGetInternalformativ/g' {} \;
	find ./deps/emsdk/fastcomp/emscripten/src -type f -exec sed -i 's/getInternalFormatParameter/getInternalformatParameter/g' {} \;

.PHONY: clean
clean:
	rm -r $(BUILD_PATH)

.PHONY: cleandeps
cleandeps:
	git submodule foreach --recursive git clean -xdf
	git submodule foreach --recursive git reset --hard

.PHONY: serve
serve:
	$(info ===== Starting HTTP server - http://localhost:8000/$(RELEASE_PATH)/out.html =====)
	python3 -m http.server || \
	python2 -m SimpleHTTPServer || \
	python -m http.server || \
	python -m SimpleHTTPServer
