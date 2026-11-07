# AI chat panel (optional)

> Tracked as issue #2 in this repo's tracker.

**Type:** feature · **Priority:** maybe later

An optional assistant panel like end-4's left sidebar: ask a question from the launcher (e.g. `?? how do I…`) or a dedicated key, with streamed answers in the island.

- **Local first:** Ollama (official repo) as the default backend; remote APIs strictly opt-in with the key stored in the system keyring (never in the repo)
- Copy / insert answer, keep a short history in `~/.local/state/kessel/ai/`
- Off by default; no network traffic unless configured

**Open questions:** which models fit a laptop without a GPU; whether to share the launcher's input or have a separate panel.
