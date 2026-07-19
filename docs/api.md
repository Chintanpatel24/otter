# API and Model Logic

- `api/logic.py` — request parsing, token rate tracking, response formatting
- `models/logic.py` — model registry, multi-model switching, file tracking
- `api/server.go` — Go server with `/v1/chat/completions`, `/v1/completions`, `/v1/models`, `/v1/health`
- All endpoints return `token_rate_per_second`
