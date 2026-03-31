---
name: midi-rekordbox
description: Use when parsing or generating Rekordbox MIDI Learn CSV mapping files, implementing MIDI-to-function lookup, working with deck channel offsets, hi-res 14-bit CC controls, or understanding DDJ/XDJ/DJM controller MIDI conventions.
---

# Rekordbox MIDI Learn CSV Protocol

Reverse-engineered from bundled controller CSVs and the official AlphaTheta MIDI Learn Operation Guide. The guide documents the UI workflow; this skill documents the **CSV wire format** that the UI reads and writes.

**Ground truth:** `references/DDJ-FLX10.midi.csv` (567 lines, 4-deck) and `references/DDJ-GRV6.midi.csv` (339 lines, 2-deck).

## File Structure

```
Line 1:  @file,1,DDJ-FLX10                    ← file marker, format version (always 1), controller name
Line 2:  #name,function,type,input,deck1,deck2,deck3,deck4,output,deck1,deck2,deck3,deck4,option,comment
Line 3+: data rows, section headers, or empty separators
```

The CSV is also the EXPORT/IMPORT format — Rekordbox's MIDI setting window reads and writes this exact structure.

## Column Definitions (15 columns, 0-indexed)

| Col | Header | Purpose | Notes |
|-----|--------|---------|-------|
| 0 | `#name` | Internal identifier | Often matches col 1; `#` prefix = not user-assignable in MIDI Learn UI |
| 1 | `function` | **Rekordbox function** (key column) | Supports modifiers: `+Shift`, `+LongPress`, `+Press` |
| 2 | `type` | Control type | See Control Types below |
| 3 | `input` | Base MIDI IN code (4-digit hex) | Empty when deck columns have full codes |
| 4-7 | `deck1`-`deck4` | Input deck assignments | Channel offsets OR full MIDI codes |
| 8 | `output` | Base MIDI OUT code (LED feedback) | Often mirrors input |
| 9-12 | `deck1`-`deck4` | Output deck assignments | Mirrors input pattern |
| 13 | `option` | Flags (semicolon-separated) | See Options below |
| 14 | `comment` | Human description | |

## MIDI Hex Format

Codes are 4-digit hex: `SSDD` — status byte + data byte.

```
Status byte = upper nibble (message type) + lower nibble (channel 0-15)

  9x = Note On      Example: 900B = Note On, Ch 0, Note 0x0B
  8x = Note Off     Example: 800B = Note Off, Ch 0, Note 0x0B
  Bx = Control Change   Example: B640 = CC, Ch 6, CC 0x40
```

Channels are 0-indexed in the CSV (0-15) but conventionally displayed as 1-16.

## Deck Assignment Patterns

### Pattern 1: Base Code + Channel Offsets (most common)
```csv
PlayPause,PlayPause,Button,900B,0,1,2,3,900B,0,1,2,3,Fast;Priority=50;Dual,Play/Pause
```
Base `900B` (Ch 0) + offsets `0,1,2,3` → Ch 0 (Deck 1), Ch 1 (Deck 2), Ch 2 (Deck 3), Ch 3 (Deck 4).

### Pattern 2: Empty Base + Full MIDI in Deck Columns
```csv
Load,Load,Button,,9646,9647,9648,9649,,,,,,,Load to Deck
```
Input column empty; each deck column has a complete 4-digit MIDI code.

### Pattern 3: Global (No Deck Assignment)
```csv
Browse,Browse,Rotary,B640,,,,,,,,,,,Browse
```
Channel 6 = global controls. All deck columns empty.

### Pattern 4: Non-Sequential Channel Offsets
```csv
PAD1_PadMode1,PAD1_PadMode1,Pad,9000,7,9,11,13,...
```
Offsets 7, 9, 11, 13 → Channels 7, 9, 11, 13 for decks 1-4. Not always sequential.

### Pattern 5: Multi-Row Per Function
```csv
FXPartSelectVocalOn,,Button,9714,,,,,9714,,,,,,FX PART SELECT VOCAL
FXPartSelectVocalOn,,Button,9914,,,,,9914,,,,,,FX PART SELECT VOCAL
FXPartSelectVocalOn,,Button,9B14,,,,,9B14,,,,,,FX PART SELECT VOCAL
```
Same function on separate rows with different MIDI codes (channels 7, 9, 11). Deck columns empty; channel is baked into the code.

## Control Types

### Verified in CSVs

| CSV Name | MIDI Message | Resolution | Description |
|----------|-------------|------------|-------------|
| `Button` | Note On/Off | — | Momentary button |
| `Pad` | Note On (velocity) | — | Velocity-sensitive pad |
| `KnobSliderHiRes` | CC (14-bit) | 0-16383 | High-resolution fader (MSB+LSB) |
| `Rotary` | CC (relative) | — | Rotary encoder (64=center, >64=CW, <64=CCW) |
| `JogRotate` | CC | — | Jog wheel rotation |
| `JogTouch` | Note On/Off | — | Jog wheel touch detect |
| `JogIndicator` | — | — | Jog display feedback (output only) |
| `Difference` | CC | — | Position difference (search/seek) |
| `Indicator` | — | — | Output-only LED feedback |
| `Value` | CC | — | Special: Needle Search or Velocity Sampler |
| `Parameter` | — | — | Internal config, uses `FFFx` codes (outside standard MIDI) |

### Listed in Official Guide but NOT Found in CSVs

| UI Name | Expected CSV Name | Status |
|---------|-------------------|--------|
| `Knob/Slider (0h-7Fh)` | `Knob` or `KnobSlider` | **Not observed** in DDJ-FLX10 or DDJ-GRV6 CSVs |

All faders in both CSVs use `KnobSliderHiRes` (14-bit). 7-bit knob types may exist in other controllers.

## 14-Bit Hi-Res Controls (MSB/LSB)

`KnobSliderHiRes` uses standard MIDI 14-bit CC encoding:

- **MSB**: CC 0-31 (coarse value, appears in the CSV)
- **LSB**: CC 32-63 (fine value, **implicit** — CC number = MSB CC + 32)
- Combined value: `MSB * 128 + LSB` (range 0-16383)

Example: `TempoSlider` mapped to `B000` (CC 0). The device also sends CC 32 as the LSB — this is NOT in the CSV but must be handled by any parser.

```
CSV entry:     B000 → CC 0 on base channel (MSB)
Implicit LSB:  B020 → CC 32 on same channel (LSB, not in CSV)
```

**Parser must**: recognize CC 32-63 as LSBs for CC 0-31 when the MSB maps to a `KnobSliderHiRes` function. The LSB shares the same function name and deck assignment.

## Options Field

Semicolon-separated in column 13. Example: `Fast;Priority=50;Dual`

| Option | Format | Description |
|--------|--------|-------------|
| `Fast` | flag | Priority processing for time-critical controls |
| `Priority=N` | key=value | Priority level 0-100 |
| `Dual` | flag | 4-deck mode support (DDJ-FLX10) |
| `Blink=N` | key=value | LED blink rate in milliseconds |
| `RO` | flag | Read-only: controller reports state, not user-assignable |
| `Value=N` | key=value | Config value (used with `Parameter` type) |
| `Min=N` | key=value | Minimum value |
| `Max=N` | key=value | Maximum value |

## Row Types

| Type | Column 0 | Column 1 | Example |
|------|----------|----------|---------|
| **Functional** | name | function | `PlayPause,PlayPause,Button,900B,...` |
| **Section header** | `# Name` | empty | `# Browser,,,,,,,,,,,,,,` |
| **Separator** | empty | empty | `,,,,,,,,,,,,,,` |
| **`#`-prefixed functional** | `#Name` | function | `#JogScratch,JogScratch,JogRotate,...` |
| **`#` placeholder** | `#` | function | `#,Browse+Press+Shift,Button,...` |

### `#`-Prefixed Rows

Column 0 starting with `#` marks controls not assignable through the MIDI Learn UI. Two subcategories observed:

1. **Hardwired + RO** — Controller-reported state, firmware-fixed. All jog controls, deck select indicators. Always have `RO` option. (e.g., `#JogScratch`, `#Deck3`)

2. **Hardwired, not RO** — Real input controls with fixed MIDI assignments that can't be remapped. No `RO` flag. (e.g., `#CrossFader` with `Fast`, `#ChannelFader`)

These rows have valid MIDI codes and produce real messages. A sniffer/parser should handle them.

## Special Sections

### `# State` — Status synchronization
```csv
VinylState,VinylState,Button,903A,0,1,2,3,,,,,,RO,LED State of Vinyl buttons
DeckState,DeckState,Button,903C,0,1,2,3,,,,,,RO,LED State of DECK
```

### `# illumination` — LED control (Channel 15)
```csv
LoadedIndicator,LoadedIndicator,Indicator,,,,,,,9F00,9F01,9F02,9F03,RO;Priority=100,Load illumination
JogBrightnessSetting,JogBrightnessSetting,Value,BF46,,,,,BF46,,,,,RO;Priority=100,JOG RING brightness
```
Uses `9Fxx` (Note On Ch 15) and `BFxx` (CC Ch 15).

### `# Parameter` — Internal config
```csv
JogIndicatorInterval,JogIndicatorInterval,Parameter,FFF1,,,,,,,,,,Value=12,
MidiOutInterval,MidiOutInterval,Parameter,FFF3,,,,,,,,,,Value=2,
```
`FFFx` codes are outside standard MIDI range — internal to Rekordbox.

## Channel Conventions (Hardware-Specific)

Some controls are NOT in the CSV — they're hardwired in controller firmware. These channel assignments are observed empirically:

| Controller Family | Channel | Known Controls |
|-------------------|---------|----------------|
| DDJ controllers | Ch 6 | MicLevel (CC 5), MasterLevel (CC 8), BoothLevel (CC 9), CueMasterMix (CC 12), HeadphonesLevel (CC 13) |
| XDJ all-in-ones | Ch 4 | MasterLevel (CC 24), BoothLevel (CC 25) |
| DJM mixers | Ch 0 | MasterLevel (CC 24), BoothLevel (CC 25) |
| All (illumination) | Ch 15 | LED feedback (`9Fxx`, `BFxx`) |

**Note:** DDJ Ch 6 mappings confirmed on DDJ-GRV6 only. XDJ/DJM mappings are unverified — derived from community reports.

## Lookup Algorithm

To find a Rekordbox function from a received MIDI message:

```
1. Parse message: type (note_on/note_off/cc), channel, data1
2. Build key: "{type}:{channel}:{data1}"
3. Search CSV rows:
   a. Pattern 1: base_code channel + deck_offset == message channel?
   b. Pattern 2: deck column contains full MIDI code matching message?
4. If CC 32-63 and no direct match:
   → Check CC (data1 - 32) as MSB for KnobSliderHiRes — this is the LSB
5. Return function from column 1, control type from column 2
```

## Verification Status

| Claim | Evidence | Confidence |
|-------|----------|------------|
| CSV structure (15 cols, @file header) | 2 CSVs + official IMPORT/EXPORT | High |
| Deck offset patterns 1-4 | Verified in both CSVs | High |
| Pattern 5 (multi-row) | DDJ-GRV6 lines 223-226 | High |
| Control types (verified list) | Exhaustive grep of both CSVs | High |
| `Knob`/`KnobSlider` types | NOT found in either CSV | Unverified |
| 14-bit MSB/LSB | Working parser + MIDI spec | High |
| `#` prefix = not UI-assignable | Observed behavior, not confirmed | Medium |
| DDJ Ch 6 built-in controls | Confirmed on DDJ-GRV6 hardware | Medium |
| XDJ/DJM channel conventions | Community reports, no hardware test | Low |

## Sources

- Ground truth CSVs: `references/DDJ-FLX10.midi.csv`, `references/DDJ-GRV6.midi.csv` (bundled with this skill)
- Official guide: AlphaTheta "MIDI LEARN Operation Guide" for rekordbox 7.0.5 (UI workflow, control type definitions)
- CSV source: `/Applications/rekordbox 7/rekordbox.app/Contents/Resources/MidiMappings/`
- MIDI spec: https://www.midi.org/specifications (14-bit CC, status bytes)
