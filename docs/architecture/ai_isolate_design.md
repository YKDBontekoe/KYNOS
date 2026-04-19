# ADR-001: AI Isolate Architecture

## Status
Accepted

## Context
Running Gemma 4 E2B inference synchronously on the UI thread would block the
120 Hz ProMotion render loop (frame budget: 8.33 ms). A typical prefill pass
on iPhone 17 Pro takes ~36 ms, and decode runs at ~56 tokens/s, meaning each
token takes ~18 ms — more than two full frames.

## Decision
Run the LiteRT-LM inference engine inside a dedicated **Background Isolate**
with its own memory heap. The UI communicates with it exclusively via
`SendPort` / `ReceivePort` message passing.

```
Main Isolate                     Background Isolate
─────────────────                ─────────────────────────────
KynosApp (120 Hz)                aiIsolateEntryPoint()
CoachChatPage                    │
  │ InferenceRequest ──────────► │ LiteRT-LM session
  │                              │   prefill → decode loop
  │ ◄────── InferenceChunk  ─────│   yield token
  │ ◄────── InferenceChunk  ─────│   yield token
  │ ◄────── InferenceDone   ─────│   done
```

## Consequences
- **Positive**: UI thread is never blocked; smooth 120 FPS maintained.
- **Positive**: Background Isolate can be killed when app suspends to free RAM.
- **Negative**: Objects cannot be shared between isolates; all data must be
  serialised (primitives / `TransferableTypedData`).
- **Negative**: Initialising the LiteRT-LM session across an isolate boundary
  adds ~200–400 ms cold-start latency.

## Alternatives Considered
- **Compute isolates** (`compute()` helper) — too coarse, not streaming.
- **Platform channels to native thread** — possible but adds FFI complexity
  duplicating what LiteRT-LM already provides.
