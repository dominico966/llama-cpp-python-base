from waitress import serve
from ..model_serve import create_app # Or from myapp import create_app; app = create_app()

def main():
    print("🔥 LLM 서버 시작됨! http://localhost:5000/chat")
    serve(create_app(), host='0.0.0.0', port=5000)

