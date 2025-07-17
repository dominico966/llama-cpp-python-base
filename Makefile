BUILD_OUTD=./build
MODEL_OUTD=$(BUILD_OUTD)/models

MODEL_SRCD=./models
MODEL_NAME=$(MODEL_SRCD)/Nous-Hermes-2-Mistral-7B-DPO.Q4_K_M.gguf

BUILD_OUTF=my_ai

export CC=clang-cl
export CXX=clang-cl
export CMAKE_BUILD_PARALLEL_LEVEL=12

all: run

run:
	uv run main.py

prepare: clean_prepare $(MODEL_NAME) 
# 	which nvcc || echo "must install nvcc.exe"
# 	which uv || winget install --id=astral-sh.uv -e
	CMAKE_ARGS='-G Ninja -DGGML_CUDA=on -DLLAVA_BUILD=off' FORCE_CMAKE=1 uv add llama-cpp-python --force-reinstall --no-cache-dir --upgrade --verbose

$(MODEL_NAME):
	@mkdir -p models
	wget https://huggingface.co/NousResearch/Nous-Hermes-2-Mistral-7B-DPO-GGUF/resolve/main/Nous-Hermes-2-Mistral-7B-DPO.Q4_K_M.gguf?download=true -O $@

clean_prepare:
	rm -Rf .venv
	rm -Rf $(BUILD_OUTD)
	uv cache clean
	uv venv
	uv pip install pip

clean:
	rm -Rf $(BUILD_OUTD)/$(BUILD_OUTF)

$(BUILD_OUTD)/$(MODEL_NAME):
	cp -r $(MODEL_NAME) $(BUILD_OUTD)/

build: $(BUILD_OUTD)/$(MODEL_NAME)
	uv run nuitka --clang --show-scons --onefile ./main.py --jobs=12 --output-dir=$(BUILD_OUTD) --output-filename=$(BUILD_OUTF)

test:
	( cd $(BUILD_OUTD); ./$(BUILD_OUTF) )

.PHONY: all run prepare clean_prepare clean build test
