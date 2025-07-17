ifeq ($(SHELL),/bin/sh)
RM = rm -Rf
MKDIR_P = mkdir -p
CP_R = cp -r
CURL=curl
else
SHELL := powershell.exe
.SHELLFLAGS := -NoProfile -Command

RM = Remove-Item -Recurse -Force
MKDIR_P = New-Item -ItemType Directory -Force
CP_R = Copy-Item -Recurse -Force
CURL=curl.exe
endif

BUILD_OUTD=./build
MODEL_OUTD=$(BUILD_OUTD)/models

MODEL_SRCD=./models
MODEL_NAME=$(MODEL_SRCD)/Nous-Hermes-2-Mistral-7B-DPO.Q4_K_M.gguf

ifeq ($(OS),Windows_NT)
BUILD_OUTF=my_ai.exe
else
BUILD_OUTF=my_ai
endif

# CC / CXX compiler
# set your compiler on PATH environ
export CC=clang-cl
export CXX=clang-cl

# llama-cpp-pyhon build option
export LLAMA_CPP_OPT=-DGGML_CUDA=on -DLLAVA_BUILD=off

# llama-cpp-python build cmake option
export CMAKE_ARGS=-G Ninja $(LLAMA_CPP_OPT)
export CMAKE_BUILD_PARALLEL_LEVEL=12
export FORCE_CMAKE=1 

all: run

run:
	uv run main.py

prepare: clean_prepare $(MODEL_NAME) 
	uv add llama-cpp-python --force-reinstall --no-cache-dir --upgrade --verbose

$(MODEL_NAME):
	-$(MKDIR_P) $(MODEL_SRCD)
	$(CURL) -L https://huggingface.co/NousResearch/Nous-Hermes-2-Mistral-7B-DPO-GGUF/resolve/main/Nous-Hermes-2-Mistral-7B-DPO.Q4_K_M.gguf?download=true -o $@

clean_prepare:
	-$(RM) .venv
	-$(RM) $(BUILD_OUTD)
	uv cache clean
	uv venv
	uv pip install pip

clean:
	-$(RM) $(BUILD_OUTD)/$(BUILD_OUTF)

$(BUILD_OUTD)/$(MODEL_NAME):
	-$(CP_R) $(MODEL_SRCD) $(BUILD_OUTD)/

build: $(BUILD_OUTD)/$(MODEL_NAME)
	uv run nuitka --clang --show-scons --onefile ./main.py --jobs=12 --output-dir=$(BUILD_OUTD) --output-filename=$(BUILD_OUTF)

test:
	$(SHELL) $(BUILD_OUTD)/$(BUILD_OUTF)

.PHONY: all run prepare clean_prepare clean build test
