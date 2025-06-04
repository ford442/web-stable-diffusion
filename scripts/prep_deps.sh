#!/bin/bash
# This file prepares all the necessary dependencies for the web build.
set -euxo pipefail

emcc --version
npm --version
cargo --version

TVM_HOME_SET="${TVM_HOME:-}"

if [[ -z ${TVM_HOME_SET} ]]; then
    if [[ ! -d "3rdparty/tvm" ]]; then
        echo "Do not find TVM_HOME env variable, cloning a version as source".
        git clone https://github.com/ford442/tvm /content/RAMDRIVE2/web-stable-diffusion/3rdparty/tvm --branch unity --recursive
    fi
    export TVM_HOME="/content/RAMDRIVE2/web-stable-diffusion/3rdparty/tvm"
fi

export TOKENZIER_WASM_HOME="/content/RAMDRIVE2/web-stable-diffusion/3rdparty/tokenizers-wasm"

mkdir -p dist
cd ${TVM_HOME}/web && make && npm install && npm run bundle && cd -
git submodule update --init
cd ${TOKENZIER_WASM_HOME} && wasm-pack build --target web && cd -
rm -rf dist/tokenizers-wasm
cp -r ${TOKENZIER_WASM_HOME}/pkg dist/tokenizers-wasm
cd -
echo "Exporting tvmjs runtime dist files"
python -c "from tvm.contrib import tvmjs; tvmjs.export_runtime(\"dist\")"
