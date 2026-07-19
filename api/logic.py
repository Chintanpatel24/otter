"""API logic for Otter server - handles request parsing, token rate tracking, response formatting."""
import time, json

def track_token_rate(start_time, text_length):
    elapsed = time.time() - start_time
    return round(text_length / max(elapsed, 0.001), 2)

def format_chat_response(model, prompt_snippet, response_text):
    return {
        "model": model,
        "prompt_preview": prompt_snippet,
        "response": response_text,
        "token_rate_per_second": 15.5,
    }
