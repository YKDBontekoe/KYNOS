# KYNOS

> Private, local-first agentic health coach — personal baselines, visual investigations, and Zero-Knowledge privacy.

KYNOS combines deterministic health analysis with an optional Gemma language
model running **on-device** via LiteRT-LM. It connects sleep, cardiovascular
signals, movement, exercise, and subjective check-ins into daily guidance and
interactive visual investigations. OpenRouter is an explicit fallback; raw
health history, notes, visual data, and coach memory remain local.

---

## Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.41+ / Dart 3.11+ |
| **State** | Riverpod 2 (`flutter_riverpod` + `riverpod_annotation`) |
| **Navigation** | go_router 14 |
| **Models** | freezed + json_serializable |
| **Health Data** | `health` package — HealthKit (iOS) + Health Connect (Android) |
| **On-Device AI** | Gemma 4 E2B INT4 via LiteRT-LM (Background Isolate) |
| **Export** | Protocol Buffers (model weights) |
| **Testing** | flutter_test + mocktail |

---

## Project Structure

```
kynos/
├── CODEMAP.md                        # Agent navigation index (read first)
├── AGENTS.md                         # Architecture rules for AI agents & contributors
├── CLAUDE.md                         # Claude Code instructions
│
├── lib/
│   ├── main.dart                     # Entry point
│   ├── app/                          # MaterialApp, router, shell
│   ├── core/                         # Constants, errors, theme tokens
│   ├── domain/                       # Entities, repos, use-cases (pure Dart)
│   ├── infrastructure/               # Platform integrations (repo implementations)
│   ├── features/                     # Vertical UI slices
│   │   └── <feature>/
│   │       ├── presentation/pages/
│   │       ├── presentation/widgets/
│   │       └── providers/
│   └── shared/                       # Cross-feature widgets & DI providers
│       ├── providers/                # Binds infrastructure → Riverpod
│       ├── utils/
│       └── widgets/
│
├── test/                             # Mirrors lib/ structure
├── tool/generate_codemap.dart        # Regenerates CODEMAP.md auto sections
└── docs/architecture/                # ADRs and folder rationale
```

See [CODEMAP.md](CODEMAP.md) for feature entry points and [docs/architecture/folder_structure.md](docs/architecture/folder_structure.md) for layer rationale.

---

## For AI Agents

| Step | Resource |
|------|----------|
| 1. Onboard | [docs/agents/README.md](docs/agents/README.md) — hub, skills index, validation |
| 2. Navigate | [CODEMAP.md](CODEMAP.md) — feature entry points, hot files |
| 3. Follow rules | [AGENTS.md](AGENTS.md) — architecture, PR lifecycle, design system |
| 4. Quick ref | [CLAUDE.md](CLAUDE.md) — bootstrap commands |
| 5. Skills | [`.cursor/skills/`](.cursor/skills/) — `/add-feature`, `/validate-change`, `/open-pr`, etc. |

**Branch naming:** `cursor/<descriptive-name>-d1bd`

**Before opening a PR:** `flutter analyze`, `flutter test`, `flutter build web`, regenerate CODEMAP if `lib/` structure changed.

---

## Getting Started

```bash
cp .env.example .env
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart run tool/generate_codemap.dart
flutter analyze
flutter test
flutter run -d "iPhone 16 Pro"
```

## SideStore Source

KYNOS can be distributed to SideStore from this source URL:

`https://raw.githubusercontent.com/YKDBontekoe/KYNOS/main/docs/sidestore-source.json`

Each GitHub release updates the source metadata and points SideStore to the latest
`kynos-ios-unsigned.ipa` asset.

---

## On-Device AI Architecture

The LLM runs in a **Background Isolate** to never block the 120 Hz UI thread:

```
Main Isolate (120 Hz UI)              Background Isolate (AI)
─────────────────────────             ─────────────────────────
CoachChatPage                         aiIsolateEntryPoint()
  │                                   │
  │─── InferenceRequest ─────────────►│  LiteRT-LM · Metal/OpenCL
  │◄── InferenceChunk ────────────────│  Gemma 4 E2B — 128K ctx
  │◄── InferenceDone ─────────────────│  done
```

---

## Privacy

- All biometric processing is on-device (`AppConstants.zeroKnowledgeMode = true`)
- No central database — no breach surface

---

## Roadmap

- [x] `v0.1` — Flutter scaffold, design system, architecture rules
- [x] `v0.2` — HealthKit integration + dashboard metrics
- [x] `v0.3` — AI coach chat with streaming Gemma output
- [x] `v0.4` — Nexus Lab biomechanics training loop
- [ ] `v1.0` — App Store submission
