set -euox pipefail
GAME_NAME=jam

mkdir -p build
pushd build
odin build ../src/desktop -out:${GAME_NAME} -debug -vet -strict-style
popd
