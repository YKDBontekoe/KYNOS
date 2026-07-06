# KYNOS — Advanced Continuous Improvement Agents

> **Agent hub:** [docs/agents/README.md](agents/README.md) · **Skills:** `.cursor/skills/audits/`

These prompts are designed to be run by AI agents on a recurring basis. Each prompt
has a corresponding Cursor skill under `.cursor/skills/audits/` — invoke with
`/audit-<name>`. Skills use `disable-model-invocation: true` so they only run when
explicitly requested.

**Architecture (actual):** `features/ → domain/ ← infrastructure/` with
`shared/providers/` as the DI composition root. There is **no `data/` layer yet**.

| # | Prompt | Skill | AGENTS.md reference |
|---|--------|-------|---------------------|
| 1 | Architectural Integrity Sentinel | `/audit-architecture` | §5 Dependency Rule |
| 2 | 120Hz ProMotion Performance | `/audit-performance` | §6 State, §14 UI |
| 3 | Zero-Knowledge Privacy Guardian | `/audit-privacy` | §11 Privacy |
| 4 | AI Coach Isolate Specialist | `/audit-ai-isolate` | §10 On-Device AI |
| 5 | Glassmorphism & Motion Designer | `/audit-ui-polish` | §14 UI Components |
| 6 | Automated Quality & Test Coverage | `/audit-test-coverage` | §13 Testing |
| 7 | Health Data Integrity Specialist | `/audit-health-data` | §9 Error Handling |
| 8 | Biomechanics Model Tuner | `/audit-biomechanics` | §10 On-Device AI |
| 9 | Documentation & ADR Governance | `/audit-documentation` | §2 Repository Map |
| 10 | Modern Dart & Flutter Optimization | `/audit-dart-modernization` | §15 What NOT to Do |

All audits require **empirical proof of work** (see each skill for specifics).

---

## 1. The Architectural Integrity Sentinel (AGENTS.md §5)
**Role:** Senior Software Architect
**Objective:** Continuously audit and reinforce the `features → domain ← infrastructure` dependency rule.

### **Technical Instructions:**
1. **Audit Phase:** Map all imports in `lib/features/`. Use `grep` or static analysis to find any import that bypasses the `domain` layer (e.g., a Feature importing a concrete Repository or another Feature's internal widgets).
2. **Refactoring Phase:** If a violation is found, extract the shared logic into a `domain` use-case or entity. Ensure the `domain` layer remains 100% free of Flutter, Riverpod, or third-party package dependencies.
3. **Optimisation:** Identify "Fat Features" and propose splitting them into smaller, more cohesive vertical slices.

### **Agent Self-Reflection & Evaluation:**
- "Does any class in `lib/domain/` import `package:flutter`? (If yes, abort and refactor)."
- "Is the business logic leaked into the `infrastructure` layer, or is it properly encapsulated in a UseCase?"
- "Did I use `abstract interface class` for all repository contracts to ensure testability?"

### **Proof of Work (Mandatory):**
- **Build Proof:** Output of a successful `flutter analyze` showing 0 errors/warnings.
- **Architectural Proof:** A clean `bash scripts/check_architecture.sh` run.

**Skill:** `.cursor/skills/audits/audit-architecture/SKILL.md`

---

## 2. The 120Hz ProMotion Performance Agent (AGENTS.md §14)
**Role:** Graphics & Performance Engineer
**Objective:** Proactively hunt for jank and ensure 120Hz scrolling fidelity.

### **Technical Instructions:**
1. **Profiling Phase:** Analyze complex widgets (like `DashboardPage` or `NexusLab`) for rebuild triggers. Use `ref.select` to ensure providers only notify listeners on specific field changes (e.g., `hrvMs`) rather than the entire `HealthSummary`.
2. **Optimization:** Evaluate `BackdropFilter` and `ImageFilters` in `GlassCard`. If multiple glass cards are on screen, ensure they don't cause GPU overdraw.
3. **Execution:** Implement `const` constructors where possible and use `RepaintBoundary` for heavy animations.

### **Agent Self-Reflection & Evaluation:**
- "Did I check the frame budget? (At 120Hz, I only have 8.3ms per frame)."
- "Am I using `ListView.builder` for all potentially long lists to ensure lazy loading?"
- "Did I verify that my change didn't increase the widget rebuild count unnecessarily?"

### **Proof of Work (Mandatory):**
- **Visual Proof:** A screen recording of the app running with the **Performance Overlay** enabled. The bars must stay consistently below the 8.3ms line.
- **Optimization Log:** A list of widgets converted to `const` or optimized via `ref.select`.

**Skill:** `.cursor/skills/audits/audit-performance/SKILL.md`

---

## 3. The Zero-Knowledge Privacy Guardian (AGENTS.md §11)
**Role:** Security & Privacy Specialist
**Objective:** Ensure biometric data never leaves the device or enters a log stream.

### **Technical Instructions:**
1. **Leak Detection:** Scan the codebase for any `print()`, `debugPrint()`, or `logger` calls that take `HealthSummary`, `AthleteProfile`, or `BiomechanicsSample` as arguments.
2. **Path Audit:** Trace the lifecycle of data from `HealthKitRepository` to the UI. Ensure no intermediate service (like a network interceptor) could accidentally capture this data.
3. **Hardening:** Verify that `AppConstants.zeroKnowledgeMode` is strictly enforced and that no 'experimental' cloud-sync code has been merged without ZK-proofs.

### **Agent Self-Reflection & Evaluation:**
- "If I were a malicious actor with access to the application logs, could I reconstruct a user's heart rate history? (The answer must be No)."
- "Did I accidentally 'stringify' a sensitive object into a JSON error report?"
- "Does the `LocalExportService` follow the 'User-Initiated Only' rule for data movement?"

### **Proof of Work (Mandatory):**
- **Audit Proof:** A comprehensive `grep` or `ripgrep` report showing that sensitive variable names (e.g., `hrvMs`, `rhrBpm`) never appear in logging statements.
- **Build Proof:** Verify `AppConstants.zeroKnowledgeMode == true`.

**Skill:** `.cursor/skills/audits/audit-privacy/SKILL.md`

---

## 4. The AI Coach Isolate Specialist (AGENTS.md §10)
**Role:** Systems & Concurrency Engineer
**Objective:** Evolve the background isolate bridge for Gemma LLM inference.

### **Technical Instructions:**
1. **Isolate Audit:** Check the `AiIsolateBridge` for potential memory leaks. Ensure that the isolate is properly killed and the port is closed when the `CoachChatPage` is disposed.
2. **Gemma Tuning:** Improve the token-streaming efficiency. Ensure that the 'Typewriter' effect in the UI is driven by a `Stream` and doesn't trigger full-page rebuilds.
3. **Robustness:** Implement a 'Thermal Monitor' check. If the device reports high thermal state, the agent should propose delaying LLM load to prevent aggressive OS throttling.

### **Agent Self-Reflection & Evaluation:**
- "Does the background isolate communicate solely through the Isolate Bridge protocol? (No shared memory/state leaks)."
- "Is the UI responsive (120Hz) while the Gemma model is generating tokens?"
- "Did I handle the 'Out of Memory' scenario gracefully on devices with < 6GB RAM?"

### **Proof of Work (Mandatory):**
- **Visual Proof:** A video showing a chat session where the text streams smoothly while the user is actively scrolling or interacting with other UI elements.
- **Isolate Log:** Proof of the background isolate's RAM consumption during inference.

**Skill:** `.cursor/skills/audits/audit-ai-isolate/SKILL.md`

---

## 5. The Glassmorphism & Motion Designer (AGENTS.md §14)
**Role:** High-End UI/UX Developer
**Objective:** Maintain the "Liquid Glass" aesthetic and interactive feedback loops.

### **Technical Instructions:**
1. **Visual Iteration:** Refine the `GlassCard` borders. Ensure the tinting matches the latest Apple Fitness iOS 18 design language.
2. **Interactive Feedback:** Implement `HapticFeedback.mediumImpact()` on primary actions and `selectionClick()` on scrolling elements.
3. **Motion Design:** Ensure all transitions (e.g., moving from Today to Lab) use `go_router` custom transitions that feel "fluid" rather than "mechanical."

### **Agent Self-Reflection & Evaluation:**
- "Does the Glassmorphism look premium in both Light and Dark modes?"
- "Is the haptic feedback purposeful, or is it just 'noise'?"
- "Did I follow the spacing tokens in `core/theme/spacing.dart` strictly?"

### **Proof of Work (Mandatory):**
- **Visual Proof:** High-resolution screenshots (Light vs Dark mode) and a video demonstrating the fluid transitions and haptic feedback triggers.
- **Thematic Proof:** Verification that all colors used are from the `AppTheme` palette.

**Skill:** `.cursor/skills/audits/audit-ui-polish/SKILL.md`

---

## 6. The Automated Quality & Test Coverage Agent (AGENTS.md §13)
**Role:** SDET / Quality Engineer
**Objective:** Continuously shrink the "Untested Code" surface area.

### **Technical Instructions:**
1. **Coverage Analysis:** Run `flutter test --coverage`. Identify any UseCase in `lib/domain/usecases/` with < 100% line coverage.
2. **Test Expansion:** Write unit tests using `mocktail` for repository fakes. Write Widget tests for every shared widget in `lib/shared/widgets/`.
3. **Regression Hunting:** Ensure every bug fix is accompanied by a reproduction test case that remains in the suite.

### **Agent Self-Reflection & Evaluation:**
- "Did I mock the external dependencies correctly, or am I hitting 'real' platform APIs in my tests?"
- "Are my widget tests checking for 'Visual Correctness' (finding text/icons) or just 'Not Crashing'?"
- "Is the `test/` directory structure a 1:1 mirror of `lib/`?"

### **Proof of Work (Mandatory):**
- **Test Proof:** Output of `flutter test` showing 0 failures.
- **Coverage Proof:** An HTML coverage report (or summary) showing increased percentage in the target feature.

**Skill:** `.cursor/skills/audits/audit-test-coverage/SKILL.md`

---

## 7. The Health Data Integrity Specialist
**Role:** Data Engineer / Health Specialist
**Objective:** Improve the robustness and accuracy of biometric data processing.

### **Technical Instructions:**
1. **Aggregation Logic:** Improve the `HealthKitRepository` logic for handling multiple sleep segments or "missing hours" in the data stream.
2. **Normalization:** Ensure that HRV data (SDNN) is correctly normalized for the AI coach's context window.
3. **Error Resilience:** Improve how the app handles "Permissions Denied" or "Health Store Unavailable" states with clear, non-technical UX feedback.

### **Agent Self-Reflection & Evaluation:**
- "Does the app handle a user having 0 health data gracefully? (No empty grey screens)."
- "Is the data aggregation mathematically accurate for users who sleep across midnight?"
- "Did I follow AGENTS.md §9 for error handling (Sealed Failure hierarchy)?"

### **Proof of Work (Mandatory):**
- **Logic Proof:** Unit tests covering complex data scenarios (e.g., split sleep, daylight savings shifts).
- **Visual Proof:** Screenshot of the Dashboard showing clear "Empty State" or "Permission Required" UI.

**Skill:** `.cursor/skills/audits/audit-health-data/SKILL.md`

---

## 8. The Biomechanics Model Tuner
**Role:** Data Scientist / Biomechanics Engineer
**Objective:** Ensure the on-device regression model is numerically stable and accurate.

### **Technical Instructions:**
1. **Numerical Stability:** Implement checks for "Collinearity" in the multivariate regression (`cadence` vs `power`). If the data is too correlated, the model should propose a "Calibration Run."
2. **Incremental Training:** Refine the persistence of `β-coefficients`. Ensure they are loaded/saved atomically using Protocol Buffers to prevent data corruption.
3. **Validation:** Implement a "Confidence Score" for the predicted stride length.

### **Agent Self-Reflection & Evaluation:**
- "Is the regression math pure enough to run in a background isolate?"
- "Did I handle the 'Cold Start' problem where the user has only 1 or 2 data points?"
- "Is the Protocol Buffer schema versioned for future updates?"

### **Proof of Work (Mandatory):**
- **Mathematical Proof:** A unit test verifying the OLS prediction against a Python-verified reference dataset.
- **Visual Proof:** A screenshot of the "Nexus Lab" showing the current β-coefficients and model confidence.

**Skill:** `.cursor/skills/audits/audit-biomechanics/SKILL.md`

---

## 9. The Documentation & ADR Governance Agent
**Role:** Technical Writer / Architect
**Objective:** Ensure that the architecture docs and the code never drift apart.

### **Technical Instructions:**
1. **Synchronization Audit:** Read all `.md` files in `docs/architecture/`. Compare the "Isolate Protocol" or "Folder Structure" documentation with the actual code in `lib/`.
2. **ADR Generation:** If a significant technical decision was made (e.g., switching from Isar to Drift), generate a new ADR (`docs/architecture/adr-XXX.md`).
3. **API Docs:** Ensure all `public` methods in `domain/` have proper DartDoc comments.

### **Agent Self-Reflection & Evaluation:**
- "If a new engineer joined today, could they understand the 'Why' behind our Isolate bridge from the docs?"
- "Is the documentation concise and 'High-Signal' as per the project's tone?"

### **Proof of Work (Mandatory):**
- **Doc Proof:** A new or updated ADR file and a report on DartDoc coverage for the modified layers.

**Skill:** `.cursor/skills/audits/audit-documentation/SKILL.md`

---

## 10. The Modern Dart & Flutter Optimization Agent
**Role:** Language Specialist / Tooling Expert
**Objective:** Continuous adoption of the latest Dart/Flutter features for code safety.

### **Technical Instructions:**
1. **Language Evolution:** Proactively adopt new Dart features (e.g., Records, Pattern Matching) where they simplify the code (e.g., in `Failure` handling).
2. **Linting Upgrades:** Audit `analysis_options.yaml`. Enable stricter linting rules as the Dart ecosystem evolves (e.g., `strict-casts`, `unawaited_futures`).
3. **Build Speed:** Optimize the `build_runner` configuration to reduce generation time. Use `build.yaml` to exclude unnecessary files from the scanning process.

### **Agent Self-Reflection & Evaluation:**
- "Am I using 'Modern' patterns (Pattern matching on Sealed classes) or 'Legacy' patterns (manual Type checking)?"
- "Did I reduce the project's 'Technical Debt' by removing deprecated plugin calls?"

### **Proof of Work (Mandatory):**
- **Build Proof:** A screenshot showing a significantly faster `build_runner` execution or a clean `flutter analyze` with new strict rules.
- **Code Proof:** A 'Before vs After' snippet demonstrating a refactor to a more idiomatic Dart 3 pattern.

**Skill:** `.cursor/skills/audits/audit-dart-modernization/SKILL.md`
