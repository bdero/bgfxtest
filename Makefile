TARGET?=Debug

EMSCRIPTEN := ${CURDIR}/deps/emsdk/fastcomp/emscripten
EMSDK := ${CURDIR}/deps/emsdk/emsdk
CXX := $(EMSCRIPTEN)/em++

CXXFLAGS := -g -std=c++11 -Wall -Ideps/bx/include -Ideps/bgfx/include
LINKFLAGS := -s USE_WEBGL2=1 -s FULL_ES3=1 -s ALLOW_MEMORY_GROWTH=1

SRC_PATH := src
BUILD_PATH := build
OBJ_PATH := $(BUILD_PATH)/obj
RELEASE_PATH= $(BUILD_PATH)/bin

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
	mkdir -p $(RELEASE_PATH)
	"$(CXX)" $(LINKFLAGS) -o $@ $^

$(OBJ_PATH)/%.bc: $(SRC_PATH)/%.cpp $(CXX)
	mkdir -p $(OBJ_PATH)
	"$(CXX)" $(CXXFLAGS) -c -o $@ $<

$(BGFX_LIBS_PATH)/%Release.a:
	EMSCRIPTEN=$(EMSCRIPTEN) make -C deps/bgfx asmjs-release

$(BGFX_LIBS_PATH)/%Debug.a:
	EMSCRIPTEN=$(EMSCRIPTEN) make -C deps/bgfx asmjs-debug

$(CXX): $(EMSDK)
	cd deps/emsdk && emsdk install latest
	$(call patch_emscripten)

$(EMSDK):
	git submodule update --init --recursive

.PHONY: patch_emscripten
patch_emscripten:
	find ./deps/emsdk/fastcomp/emscripten/src -type f -exec sed -i 's/glGetInternalFormativ/glGetInternalformativ/g' {} \;

.PHONY: clean
clean:
	rm -r $(BUILD_PATH)
