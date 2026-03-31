---
name: ep133-device
description: Use when reasoning about EP-133 KO-II device organization: slot/bank layout, where samples live, how pads map to filesystem nodes, node ID system, or project structure. Does NOT cover SysEx wire format — see ep133-protocol for that.
spec-commit: 28f3c8b
---

# EP-133 KO-II Device Organization

## Hardware Facts

- **Sample slots:** 999 (numbered 1–999, global across all projects)
- **Projects:** Up to 16 reported (P01–P16). Formula and `pad_mapping.py` only verified for projects 1–9. Projects 10–16 may use a different node encoding — treat as open question.
- **Memory:** ~128 MB total
- **Audio:** 16-bit WAV; 46,875 Hz confirmed; 44,100 Hz also reported to work (open question)
- **Physical pads:** 12 per bank (labeled 0–9, `.`, `Enter`)

---

## Slot / Bank Layout

Bank 0 has 99 slots (1–99); banks 1–9 have 100 slots each. Total = 999.

| Bank | Slots | Label |
|------|-------|-------|
| 0 | 001–099 | KICK |
| 1 | 100–199 | SNARE |
| 2 | 200–299 | CYMB |
| 3 | 300–399 | PERC |
| 4 | 400–499 | BASS |
| 5 | 500–599 | MELOD |
| 6 | 600–699 | LOOP |
| 7 | 700–799 | USER 1 |
| 8 | 800–899 | USER 2 |
| 9 | 900–999 | SFX |

**Slots are global** — they represent audio data in device memory and do not belong to any project.

---

## Two Addressing Systems: Slots vs Nodes

The device uses two separate ID spaces:

### Slot IDs (1–999)
- Audio data locations
- Used for upload, download, delete
- `ko2 info <slot>`, `ko2 get <slot>`, `ko2 put <file> <slot>`

### Filesystem Node IDs
- Internal filesystem objects: directories, pad assignments, project containers
- Key fixed nodes:
  - `1000` — `/sounds/` root directory (parent node for all uploads)
  - `2000+` — Project and pad hierarchy

---

## Node ID Formula for Pad Nodes

```
node_id = 2000
        + (project_num × 1000)   # project layer
        + 100                     # groups-container layer (always present)
        + group_offset            # A=100, B=200, C=300, D=400
        + pad_file_num            # physical pad → filesystem file number
```

The `+100` mid-formula is a fixed intermediate node (the groups container) that sits between the project node and the group node. It is not optional.

**Verified for projects 1–9 only** (`pad_mapping.py` raises `ValueError` for project > 9).

### Pad → `pad_file_num` mapping

Physical pads are numbered bottom-to-top on the device; filesystem stores them top-to-bottom:

```
Physical layout:     Filesystem file_num:
  10  11  12  (top)    01  02  03
   7   8   9           04  05  06
   4   5   6           07  08  09
   1   2   3  (bot)    10  11  12
```

Pad labels map to physical positions: `7`=pad 1, `8`=pad 2, `9`=pad 3, `4`=pad 4, … `0`=pad 10, `.`=pad 11, `Enter`=pad 12.

**Example:** Project 1, Group A, Pad label `1` (physical 11, file_num=2):
`2000 + 1×1000 + 100 + 100 + 2 = 3202`

All four groups follow the same pattern with +100 offset per group. Group A fully confirmed from captures; B/C/D each confirmed at 2 data points — all consistent.

---

## Assigning a Sample to a Pad

To assign slot 74 to Group D, Pad 8 (node 9502):

1. METADATA SET on node `9500`: `{"active":9502}` — select the active pad
2. METADATA SET on node `9502`: `{"sym":74}` — assign slot 74 *(sym = "slot assignment", needs confirmation)*

To set trim points on the same pad:
- METADATA SET on node `9502`: `{"sample.start":2318,"sample.end":8006}`

**Anomaly:** `{"sym":807}` observed on node `5407` — outside the 9500+ range. Suggests pad/sample assignments may also exist in other node ranges. Needs confirmation.

---

## Projects

- Numbered 1–16 (reported); 1–9 verified in formula/code
- Switch project via SysEx (device ID `0x7C`): `{"active":<project_num × 1000>}`
  - Project 8 → `{"active":8000}`
- Each project has its own pad assignments (separate node ranges)
- Sample slots are shared across projects — same slot can be assigned to pads in multiple projects

---

## Backup File Format (`.pak`)

ZIP archive, contents observed:

```
backup.pak (ZIP)
├── meta.json          # Device info, firmware version, timestamp
├── projects/          # Project data (format of contents not fully documented)
└── sounds/            # All sample WAV files
    ├── 001 sample name.wav
    └── ...
```

Filename format: `NNN name.wav` (3-digit slot number + space + sample name).

Project-only backup: `.ppak` extension — internal format unknown.

---

## Metadata Fields on Sample Nodes

Observed on slot nodes via FileOp.METADATA GET/SET:

| Field | Example | Notes |
|-------|---------|-------|
| `channels` | `1` | Audio channels |
| `samplerate` | `46875` | Sample rate |
| `sound.playmode` | `"oneshot"` | |
| `sound.rootnote` | `60` | MIDI note |
| `sound.pitch` | `0` | |
| `sound.pan` | `0` | |
| `sound.amplitude` | `100` | |
| `envelope.attack` | `0` | |
| `envelope.release` | `255` | |
| `time.mode` | `"off"` | |
| `sound.loopstart` | `0` | Optional |
| `sound.loopend` | `<n>` | Optional |
| `sym` | `74` | Slot assigned to pad node *(needs confirmation)* |
| `sample.start` | `0` | Trim start |
| `sample.end` | `8006` | Trim end |
| `active` | `9502` | Active child node (UI navigation) |

---

## Source Files

- `PROTOCOL.md` — pad mapping formula, metadata fields
- `docs/protocol-evidence.md` — capture-based evidence
- `captures/sniffer-padmap-*.jsonl` — raw capture data
