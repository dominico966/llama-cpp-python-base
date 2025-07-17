import os, sys
import json
from flask import Flask, request, jsonify
from llama_cpp import Llama

PROJECT_ROOT = os.getcwd()
MODEL_PATH = os.path.join(PROJECT_ROOT, 'models', 'Nous-Hermes-2-Mistral-7B-DPO.Q4_K_M.gguf')
print(f'MODEL_PATH = {MODEL_PATH}')

# 모델 로드 (최대 1회만!)
llm = Llama(
    model_path=MODEL_PATH,
    n_ctx=4096,
    n_threads=12,
    n_gpu_layers=64
)

def create_app():
    app = Flask(__name__)

    # 세션별 히스토리 저장 (간단하게 메모리 dict로)
    session_histories = {}

    def messages_to_prompt(messages):
        prompt = ""
        for msg in messages:
            prompt += f"<|{msg['role']}|>\n{msg['content']}\n"
        prompt += "<|assistant|>\n"
        return prompt

    def prune_history(messages, max_tokens=3000):
        while True:
            prompt_str = messages_to_prompt(messages)
            try:
                tokens = llm.tokenize(prompt_str.encode("utf-8"))
            except Exception as e:
                print("⚠️ 토크나이즈 실패:", e)
                break

            print(f"🧮 현재 메시지 수: {len(messages)} / 토큰 수: {len(tokens)}")
            if len(tokens) <= max_tokens:
                break

            # system 메시지 제외하고 가장 오래된 user/assistant 페어 삭제
            for i, msg in enumerate(messages):
                if msg["role"] != "system":
                    messages = messages[i+2:]
                    break

        return messages

    @app.route("/chat", methods=["POST"])
    def chat():
        print("✅ 요청 도착함")
        print("Headers:", dict(request.headers))
        print("Raw Data:", request.data)

        try:
            data = json.loads(request.data.decode("utf-8"))
        except Exception as e:
            return jsonify({"error": f"JSON 디코딩 실패: {e}"}), 400

        print("Parsed JSON:", data)

        session_id = data.get("session_id", "default")
        user_msg = data.get("message")
        if not isinstance(user_msg, str):
            return jsonify({"error": "message 필드는 문자열이어야 합니다."}), 400

        history = session_histories.get(session_id, [])
        if not history:
            history.append({"role": "system", "content": "You are report printer. just print only formatted text."})
        history.append({"role": "user", "content": user_msg})
        history = prune_history(history)

        # 모델 호출
        resp = llm.create_chat_completion(
            messages=history,
            max_tokens=4096,
            temperature=0.7,
            top_p=0.95
        )
        assistant_msg = resp["choices"][0]["message"]["content"]

        history.append({"role": "assistant", "content": assistant_msg})
        session_histories[session_id] = history
        
        # ✅ 히스토리 출력
        print("💬 모델에 넘기는 히스토리:")
        for m in history:
            role = m['role']
            content = m['content'].replace("\n", "\\n")[:100]
            print(f" - {role}: {content}")

        # ✅ 프롬프트로 어떻게 보이는지 출력
        print("📝 Chat Prompt Preview:")
        print(messages_to_prompt(history))

        return jsonify({"response": assistant_msg})
    
    return app
