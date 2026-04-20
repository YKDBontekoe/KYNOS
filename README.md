# KYNOS

> On-device AI running coach — personalised biomechanics, Zero-Knowledge privacy, 120 Hz ProMotion.

KYNOS runs a Gemma 4 E2B language model **on-device** via LiteRT-LM. It analyses
your biometrics from Apple HealthKit or Google Health Connect and trains a
personalised biomechanical stride model — all without your data ever leaving
the device.

---

## Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.41+ / Dart 3.11+ |
| **State** | Riverpod 2 (`flutter_riverpod` + `riverpod_annotation`) |
| **Navigation** | go_router 14 |
| **Models** | freezed + json_serializable |
| **Storage** | Isar 3 (local NoSQL) |
| **Health Data** | `health` package — HealthKit (iOS) + Health Connect (Android) |
| **On-Device AI** | Gemma 4 E2B INT4 via LiteRT-LM (Background Isolate) |
| **Export** | Apache Parquet (history) · Protocol Buffers (model weights) |
| **Testing** | flutter_test + mocktail |

---

## Project Structure

```
kynos/
├── AGENTS.md                         # Architecture rules for AI agents & contributors
├── CLAUDE.md                         # Claude Code instructions
│
├── lib/
│   ├── main.dart                     # Entry point
│   ├── app/
│   │   ├── app.dart                  # Root MaterialApp.router + ProviderScope
│   │   └── router.dart               # go_router config + Routes constants
│   │
│   ├── core/                         # Zero Flutter-dependency utilities
│   │   ├── constants/app_constants.dart    # RAM budgets, thresholds, flags
│   │   ├── errors/failures.dart            # Sealed Failure hierarchy
│   │   ├── extensions/               # Dart extension methods
│   │   ├── theme/app_theme.dart      # Dark-first design system
│   │   └── utils/                    # Pure helper functions
│   │
│   ├── domain/                       # Business logic — no Flutter imports
│   │   ├── entities/
│   │   │   ├── athlete_profile.dart  # Biomechanics baseline + ACWR
│   │   │   └── health_summary.dart   # Daily HRV / RHR / Sleep
│   │   ├── repositories/             # Abstract interfaces (contracts)
│   │   │   ├── ai_coach_repository.dart
│   │   │   ├── biomechanics_repository.dart
│   │   │   └── health_repository.dart
│   │   └── usecases/                 # One-class-one-responsibility
│   │
│   ├── data/                         # Implements domain interfaces
│   │   ├── models/                   # @freezed + @JsonSerializable DTOs
│   │   ├── repositories/             # Concrete implementations
│   │   └── datasources/
│   │       ├── health/               # HealthKit / Health Connect queries
│   │       └── local/                # Isar, Parquet, Protobuf storage
│   │
│   ├── infrastructure/               # Platform integrations
│   │   ├── ai/
│   │   │   ├── gemma/
│   │   │   │   ├── gemma_coach_repository.dart   # LiteRT-LM wrapper
│   │   │   │   └── ai_isolate_bridge.dart        # Isolate message protocol
│   │   │   └── apple_intelligence/               # Foundation Models (iOS 18+)
│   │   ├── health/
│   │   │   └── health_kit_repository.dart        # iOS HealthKit adapter
│   │   └── privacy/                              # zk-SNARK circuit wrappers
│   │
│   ├── features/                     # Vertical slices — UI owns only UI
│   │   ├── dashboard/presentation/dashboard_page.dart
│   │   ├── coach_chat/               # Streaming AI chat
│   │   ├── nexus_lab/                # Biomechanics training & cadence analysis
│   │   ├── training_plan/            # Adaptive weekly plan
│   │   └── settings/                 # Profile, permissions, developer mode
│   │
│   └── shared/
│       ├── widgets/kynos_card.dart   # Reusable components
│       └── services/                 # Cross-feature singletons
│
├── test/                             # Unit + widget tests (mocktail)
├── docs/
│   ├── architecture/                 # ADR-001 AI Isolate, folder structure rationale
│   └── research/                     # Biomechanics & physiology references
└── assets/
    ├── images/
    └── models/                       # ⚠ Gitignored — download separately
```

---

## Getting Started

```bash
# Install dependencies
cp .env.example .env
flutter pub get

# Generate freezed / riverpod code
dart run build_runner build --delete-conflicting-outputs

# Run static analysis (must be clean)
flutter analyze

# Run tests
flutter test

# Run on iOS simulator
flutter run -d "iPhone 16 Pro"
```

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
  │◄── InferenceChunk ────────────────│  token-by-token decode
  │◄── InferenceDone ─────────────────│  done
```

RAM budget on iPhone 14 Pro (6 GB):

| Component | Budget |
|---|---|
| iOS + Flutter UI | ~2.5 GB |
| Gemma 4 E2B INT4 | ~2.5 GB |
| Headroom | ~1.0 GB |

---

## Biomechanics Model (Nexus Lab)

Personalised stride-length regression trained on-device:

```
ŷ = β₀ + β₁·cadence + β₂·power
```

β-coefficients are persisted via Protocol Buffers and loaded per session.
Zero data transmitted — continual learning stays entirely on-device.

---

## Privacy

- All biometric processing is on-device (`AppConstants.zeroKnowledgeMode = true`)
- Export uses zk-SNARK proofs: prove fitness claims without revealing raw data
- No central database — no breach surface

---

## Roadmap

- [x] `v0.1` — Flutter scaffold, design system, architecture rules
- [ ] `v0.2` — HealthKit integration + dashboard metrics
- [ ] `v0.3` — AI coach chat with streaming Gemma output
- [ ] `v0.4` — Nexus Lab biomechanics training loop
- [ ] `v0.5` — Adaptive training plan generation
- [ ] `v0.6` — Parquet export + Developer Mode
- [ ] `v1.0` — App Store submission
