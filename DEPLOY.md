# Развёртывание

## Архитектура

```
Телефон (Termius) ──SSH──▶ Мак Мини (openclaude)
                                    │
                    ┌───────────────┴───────────────┐
                    ▼                               ▼
              Комп 1 (Ollama)               Комп 2 (Ollama)
              :11434                        :11434
```

Все машины в одной Tailscale-сети — никаких открытых портов наружу.

---

## Мак Мини — только обёртка

```bash
# Сборка
bun install && bun run build

# Алиасы в ~/.zshrc (заменить IP на Tailscale-адреса компов)
alias oc1='CLAUDE_CODE_USE_OPENAI=1 OPENAI_API_KEY=none \
  OPENAI_BASE_URL=http://<tailscale-ip-comp1>:11434/v1 \
  OPENAI_MODEL=${MODEL:-qwen2.5-coder:7b} \
  node ~/openclaude/dist/cli.mjs'

alias oc2='CLAUDE_CODE_USE_OPENAI=1 OPENAI_API_KEY=none \
  OPENAI_BASE_URL=http://<tailscale-ip-comp2>:11434/v1 \
  OPENAI_MODEL=${MODEL:-gemma4} \
  node ~/openclaude/dist/cli.mjs'
```

```bash
oc1                      # дефолтная модель на компе 1
MODEL=gemma4 oc2         # конкретная модель на компе 2
```

---

## Компы с моделями — разрешить внешние подключения

Ollama по умолчанию слушает только localhost. Нужно:

```bash
# Linux (systemd)
sudo systemctl edit ollama
# Добавить в [Service]:
# Environment="OLLAMA_HOST=0.0.0.0"
sudo systemctl restart ollama

# Или разово:
OLLAMA_HOST=0.0.0.0 ollama serve
```

---

## Docker-вариант (для Linux-сервера)

Если нужна изоляция файловой системы — см. `docker-compose.yml`.

```bash
# Собрать образ
docker compose build

# Запустить с удалённой моделью
WORKSPACE=/path/to/project \
  OPENAI_BASE_URL=http://<tailscale-ip>:11434/v1 \
  MODEL=gemma4 \
  docker compose run openclaude
```

---

## Телефон → Мак через Tailscale

1. Установить Tailscale на Мак и компы с моделями: `tailscale up`
2. Включить SSH на Маке: Системные настройки → Общий доступ → Удалённый вход
3. Подключиться с телефона: **Termius** (Android/iOS) → SSH → Tailscale IP Мака
4. Запустить `oc1` или `oc2`

---

## Модели для тестирования

```bash
ollama pull gemma4
ollama pull qwen2.5-coder:7b
ollama pull deepseek-coder-v2:16b
ollama pull phi4:14b
ollama pull gemma3:4b
ollama pull llama3.2:3b
```

| Модель | Размер | Tool calling |
|--------|--------|-------------|
| `gemma4` | ? | протестировать |
| `qwen2.5-coder:7b` | ~4GB | хороший |
| `deepseek-coder-v2:16b` | ~9GB | отличный |
| `phi4:14b` | ~8GB | хороший |
| `gemma3:4b` | ~2.5GB | средний |
| `llama3.2:3b` | ~2GB | слабый |
