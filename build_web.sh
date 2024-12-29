set -euox pipefail
export EMSDK_QUIET=1

mkdir -p build_web
pushd build_web
odin build ../src/game -target:freestanding_wasm32 -build-mode:obj -show-system-calls -vet -strict-style

FILES="../src/wasm/main_wasm.c ../raylib/wasm/libraylib.a game.wasm.o"
FLAGS="-sUSE_GLFW=3 -sASYNCIFY -sASSERTIONS -DPLATFORM_WEB"
MEM="-sTOTAL_STACK=64MB -sINITIAL_MEMORY=128MB"
CUSTOM="--shell-file ../src/wasm/minshell.html --preload-file ../assets"
emcc -o index.html ${FILES} ${FLAGS} ${MEM} ${CUSTOM}
popd
