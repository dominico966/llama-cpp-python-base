# llama-cpp-python-base

llama-cpp-python 라이브러리 재현성을 위한 베이스 프로젝트 템플릿

## 테스트환경
- (Windows) Powershell
- (Windows) MSYS2 UCRT
---

## 📦 사전 설치

### 공통
- `cmake` (필수)
- `ninja` (필수)
  - Windows : `winget install --id=Ninja-build.Ninja -e`
- `uv` (필수)
  - Windows : `winget install uv`
  - Linux : `curl -LsSf https://astral.sh/uv/install.sh | sh`
- `make` (필수)

### CUDA 환경 (선택적)
- CUDA Toolkit 설치 및 `nvcc` 실행 파일 경로가 환경변수에 등록되어 있어야 함

### Windows 환경
- `clang-cl` 또는 `msvc` 컴파일러 필요
```Makefile
export CC=clang-cl # << change hear
export CXX=clang-cl # << change hear
```

### Linux 환경
- `clang` 또는 `gcc` 필요

---

## 🔧 초기화

```bash
make prepare
```

의존성 설치 및 초기 환경 설정을 수행합니다.

---

## 🚀 실행

```bash
make run
```

프로그램을 실행합니다.

---

## 🛠 빌드

```bash
make build
```

프로젝트를 빌드합니다.

---

## 📂 디렉토리 구조 (예시)

```
.
├── src/           # 소스 코드
├── models/        # 모델 파일 (선택적)
├── build/         # 빌드 결과물
├── Makefile
└── README.md
```

---

## 📝 참고

- CUDA 관련 설정이 필요한 경우, `Makefile` 내 `CMAKE_ARGS` 또는 환경변수를 확인하세요.
- Windows 환경에서는 `Developer PowerShell` 또는 `x64 Native Tools Command Prompt`에서 실행하는 것을 권장합니다.

