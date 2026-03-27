# Xone:K2 Mapping Reference (from Mixxx Manual)

Source: https://manual.mixxx.org/2.5/sl/hardware/controllers/allen_heath_xone_k2_k1

## Audio Interface

Built-in 4-channel USB audio (K2 only, K1 lacks this).
- Main output: channels 3-4
- Headphones: channels 1-2
- Note: reversed from typical DJ controllers — causes issues if used as system audio output

## MIDI Channel Presets

Hold bottom-right encoder during power-up to select:

| Ch | Layout | Deck Order |
|----|--------|------------|
| 15 (O) | 2 decks + 2 FX (decks center) | Default |
| 14 (N) | 2 decks + 2 FX (FX center) | |
| 13 (M) | 2 decks + 2 FX (decks left) | |
| 12 (L) | 2 decks + 2 FX (decks right) | |
| 11 (K) | 4 decks + FX | 3-1-2-4 |
| 10 (J) | 4 decks + FX | 1-2-3-4 |
| 9 (I) | 4 FX units | 3-1-2-4 |
| 8 (H) | 4 FX units | 1-2-3-4 |

## Global Controls

### Bottom Left Encoder
- Turn: tempo (all synced decks)
- Press+turn: PFL/main headphone mix
- Shift+turn: headphone gain
- Shift+press: toggle split cue

### Bottom Right Encoder
- Turn: library scroll
- Press/release: load track → first stopped deck
- Press/hold: load track → select deck via play button
- Shift+turn: main gain

## Deck Controls (per column)

### Top Encoder
- Turn: jogwheel
- Press: reset gain
- Shift+turn: gain
- Shift+press: sync lock
- Supershift+turn: key adjust
- Supershift+press: reset key

### Knobs
High / Mid / Low EQ (top to bottom)

### Buttons (below knobs)
1. PFL (shift: reset tempo | supershift: set beatgrid)
2. Cue (shift: go to start/stop | supershift: keylock)
3. Play (shift: reverse | supershift: quantize)

### Fader
Volume

## Layer System

Bottom-left button cycles layers. Shift+hold both layer+shift = supershift.

### Hotcue Layer (Red)
Buttons 1-4 = hotcues 1-4. Shift = seek. Supershift = delete.

### Intro/Outro Cue Layer (Amber)
Top to bottom: intro start, intro end, outro start, outro end.
Press = jump/set. Shift = seek (intro fast, outro slow). Supershift = delete.

### Loop Layer (Green)
1. Reloop/disable (shift: jump to loop | supershift: set in)
2. Activate loop (shift: rolling loop | supershift: set out)
3. Double size (shift: beatjump fwd | supershift: double beatjump)
4. Halve size (shift: beatjump back | supershift: halve beatjump)

## FX Controls (per column)

### Top Encoder
Press = effect focus button.
- Red: no effect focused
- Green: choosing effect (hold encoder)
- Amber: effect focused

### Knobs
Effect parameters (or individual effect controls when focused)

### Fader
Dry/wet mix

### Bottom Buttons
Assign FX unit to channels (deck 1-4, main, headphones)

## Setup Notes

- Latching layers must be OFF (factory default)
- Multiple K2/K1 units: connect via X-Link or individual USB, same mapping works
- Knobs/faders out of sync on startup until first moved (no way to query positions)
- USB disconnect without power-down blocks MIDI until replug
