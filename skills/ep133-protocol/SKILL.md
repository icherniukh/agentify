---
name: ep133-protocol
description: Use when implementing EP-133 KO-II upload/download/delete/metadata operations, debugging SysEx messages, or working with 7-bit packed encoding. Does NOT cover device organization (slots/banks/pads) — see ep133-device for that.
spec-commit: 53ccc08
---

# EP-133 KO-II SysEx Protocol

Reverse-engineered. No official documentation exists. All findings from capture analysis and working implementation in this repo.

## Message Structure

```
F0 00 20 76 33 40 [devid] [seq] 05 <packed7(raw_payload)> F7
     TE mfr ID    EP-133
```

- `00 20 76` — Teenage Engineering manufacturer ID
- `33 40` — EP-133 device family
- `[devid]` — Session identifier byte. Device echoes it back with -0x40 offset in responses. Any value works — official TE app rotates `0x60–0x6A`, our tool uses fixed values per operation type.
- `[seq]` — Sequence byte, increments 0–127 then wraps (instance variable `_seq`)
- `05` — CMD_FILE (file operations group)
- Raw payload is packed7-encoded for MIDI safety (no byte > 0x7F)

## Session Identifiers (`SysExCmd` enum in `src/core/models.py`)

These are NOT opcodes — the device accepts any value. We use consistent IDs for predictable response matching.

| ID | Name | Our usage |
|----|------|-----------|
| 0x61 | INIT | Initialization sequence |
| 0x77 | INFO | Device info queries |
| 0x75 | GET_META | Legacy metadata query — **unreliable, do not use** |
| 0x7C | PROJECT | Project switching |
| 0x7E | UPLOAD | Upload (all steps), delete, verify |
| 0x7D | DOWNLOAD | File download (GET) |
| 0x6A | LIST_FILES | File ops (LIST/METADATA/AUDITION) |

Device response ID = request ID - 0x40 (e.g., TX `0x7E` → RX `0x3E`).

## File Operations (`FileOp` enum)

| Op | Name | Usage |
|----|------|-------|
| 0x02 | PUT | Upload file |
| 0x03 | GET | Download file |
| 0x04 | LIST | List files |
| 0x05 | PLAYBACK | Playback/audition |
| 0x06 | DELETE | Delete sample |
| 0x07 | METADATA | Metadata GET/SET |
| 0x0B | VERIFY | Verify/commit |

## Initialization (Required Before Any Operations)

```
F0 7E 7F 06 01 F7                                        # Universal MIDI identity
F0 00 20 76 33 40 61 17 01 F7                            # Device handshake
F0 00 20 76 33 40 61 18 05 00 01 01 00 40 00 00 F7       # File system init
```

Init uses fixed seq bytes (0x17, 0x18), not the rolling `_seq` counter.

## Upload Protocol (PUT) — Confirmed from official TE app capture

**Evidence:** `tests/fixtures/sniffer-upload-kick-official.jsonl` (official TE app, kick-46875hz.wav → slot 97). PCM byte-for-byte match verified.

### Step 1 — Upload Init
```
F0 00 20 76 33 40 [devid] [seq] 05 <packed7(raw_payload)> F7
```
Raw payload (before packed7):
```
02 00 05 [slot_hi] [slot_lo] [node_hi] [node_lo] [size:4 BE] [name\0] [metadata_json]
```
- `02` = PUT, `00` = PUT_INIT, `05` = audio file type
- Slot: big-endian 16-bit
- Parent node: `0x03E8` (1000 = `/sounds/` directory)
- Size: 4-byte big-endian, raw PCM byte count (not WAV file size)
- Name: UTF-8 null-terminated
- Metadata: JSON string, e.g. `{"channels":1,"samplerate":46875}`

Wait for ACK response before proceeding.

### Step 2 — Data Chunks (repeated)
Raw payload: `02 01 [index_hi] [index_lo] [pcm_data...]`
- `02` = PUT, `01` = PUT_DATA
- Chunk index: BE16, sequential from 0
- Max PCM per chunk: **433 bytes** (`UPLOAD_CHUNK_SIZE`)
- Audio data: **raw LE s16 PCM** — WAV frames sent unchanged, no byte swap
- Pipelined: fire all chunks without waiting for individual ACKs, then drain

### Step 3 — Empty Sentinel (end of data)
Raw payload: `02 01 [next_index_hi] [next_index_lo]` (same format as data chunk, 0 PCM bytes)
- Chunk index = last data index + 1
- This is NOT a separate opcode — same PUT_DATA format with empty payload
- Wait for device ACK — this is the upload commit signal

### Step 4 — Verify → Metadata SET → Verify
```
VERIFY:    0B [slot_hi] [slot_lo]          (3 bytes, NO sub byte)
META_SET:  07 01 [node_hi] [node_lo] [json]
VERIFY:    0B [slot_hi] [slot_lo]          (repeat)
```
- VERIFY has no sub byte — just `fileop + BE16(target)`
- META_SET node = slot number (sample metadata lives on the slot's node)
- META_SET uses devid `0x6A` (LIST_FILES), not UPLOAD

### Step 5 — Re-initialize
Call `_initialize()` to resync device state. Official app does this too.

**Implementation:** `src/core/operations.py` → `UploadTransaction.execute()`

## Download Protocol (GET)

### Download Init (devid `0x7D`)
```
F0 00 20 76 33 40 7D [seq] 05 00 03 00 [slot_hi] [slot_lo] 00 00 00 00 00 F7
```
- `03` = GET, `00` = GET_INIT
- Slot: big-endian 16-bit
- Response contains file size (4-byte BE at decoded bytes [3:7]) = raw PCM byte count

### Download Data Chunks (devid `0x7D`)
```
F0 00 20 76 33 40 7D [seq] 05 00 03 01 [page_lo] [page_hi] F7
```
- Page: 14-bit value split into two 7-bit bytes
- Response: packed7-encoded chunk with 2-byte page echo prefix (strip before use)
- Data is **raw LE s16 PCM** — write directly, no byte swap
- Trim to `file_info["size"]` from GET_INIT response

## Delete (devid `0x7E`)

Raw payload: `06 [slot_hi] [slot_lo]`
- `06` = DELETE
- Slot: big-endian 16-bit

## Metadata Operations

### GET (`07 02 [node_hi] [node_lo] [page_hi] [page_lo]`)
- Uses devid `0x6A`
- Response: plain JSON (NOT packed7), prefixed by 4 bytes
- Paginated: stop when `}` found in accumulated JSON

### SET (`07 01 [node_hi] [node_lo] [json_data]`)
- Uses devid `0x6A`
- JSON payloads: `{"active":<node>}`, `{"sym":<slot>}`, `{"sample.start":N,"sample.end":N}`, `{"channels":N,"samplerate":N}`

### GET_META (0x75) — do NOT use
Returns stale/cached data. Official tool never uses it.

## 7-Bit (Packed7) Encoding

All large payloads must be packed7-encoded for MIDI SysEx safety.
Algorithm: for each group of up to 7 data bytes, prepend a flags byte where bit `i` holds the high bit of byte `i`. Implementation: `src/core/types.py` → `Packed7`.

## Audio Format

- **Max sample rate:** 46875 Hz (24 MHz / 512, Cirrus Logic CS42L52)
- OS 2.0+: sub-46875 Hz samples stored at original rate — do NOT upsample
- **Bit depth:** 16-bit signed, little-endian
- **Channels:** 1 (mono) or 2 (stereo)
- Upload sends raw PCM from WAV — no transformation needed

## Source Files

- Protocol docs: `PROTOCOL.md`, `docs/protocol-evidence.md`
- Message models: `src/core/models.py`
- Client transport: `src/core/client.py`
- Upload transaction: `src/core/operations.py`
- 7-bit encoding: `src/core/types.py` → `Packed7`
- Capture tools: `midi_proxy.py`, `scripts/capture_upload.py`
- Test captures: `tests/fixtures/sniffer-upload-kick-official.jsonl` (official TE app), `tests/fixtures/sniffer-upload21.jsonl`
