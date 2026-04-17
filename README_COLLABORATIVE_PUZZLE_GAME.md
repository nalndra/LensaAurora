# Collaborative Puzzle Game (CPG) - Implementation Guide

## Paper Reference
**"Collaborative Puzzle Game: a Tabletop Interactive Game for Fostering Collaboration in Children with Autism Spectrum Disorders (ASD)"**
- Authors: A. Battocchi, F. Pianesi, D. Tomasini, M. Zancanaro, et al.
- Research Institution: Fondazione Bruno Kessler, University of Trento, University of Haifa

## Core Concept

The Collaborative Puzzle Game implements **Enforced Collaboration (EC)** - a set of interaction rules that force two players to perform joint actions on digital objects (simultaneous touch, drag, and release) while preventing or nullifying individually performed actions.

### Key Educational Benefits for Children with ASD

1. **Leverages Visuo-Spatial Strengths** 
   - Children with ASD typically have higher visuo-spatial abilities than typically developing peers
   - Puzzle-solving relies primarily on visual search and disembedding tasks

2. **Forces Collaborative Behaviors**
   - Requires shared attention and joint focus on objects
   - Encourages negotiation and coordination
   - Reduces social cognitive demands while increasing interaction

3. **Predictable, System-Provided Rules**
   - Rules don't vary between participants/sessions
   - Don't add cognitive load by being context-dependent
   - Less affected by social interpretation issues

## Implementation Architecture

### 1. **Models** (`puzzle_model.dart`)

```dart
PuzzleModel
├── id: String
├── title: String
├── numberOfPieces: int
├── pieces: List<PuzzlePiece>
└── boardSize: Size

PuzzlePiece
├── currentPosition: Offset
├── gridX, gridY: int (correct position)
├── isPlaced: bool
├── fingersOnThis: int (tracks multi-touch)
└── isWithinCorrectPosition()
```

### 2. **Controller Logic** (`collaborative_puzzle_game_controller.dart`)

#### Enforced Collaboration Mechanism

```
Player 1 touches piece    → piece.fingersOnThis = 1 → ❌ Can't move
Player 2 joins touch      → piece.fingersOnThis = 2 → ✅ Can move
Both drag together        → Successfully moving
One releases first        → piece.fingersOnThis = 1 → ❌ Can't move anymore
                                                        Piece snaps back
```

#### Key Methods

- `onFingerDown(pointerId, piece)` - Increments finger counter
- `onFingerUp(pointerId, piece)` - Decrements finger counter  
- `onPieceDragged(piece, offset)` - Only allows drag if 2+ fingers
- `onPieceReleased(piece, position)` - Checks correct placement
- `_checkPiecePlacement()` - Validates position against solution area

### 3. **Game Statistics Tracked** (Based on Research Paper)

```
GameStats
├── totalMoves                   # All pick-drag-drop sequences
├── functionalMoves              # Moves contributing to puzzle
├── coordinationMoves            # Negotiation/coordination moves
├── correctPlacements            # Successful pieces
├── incorrectAttempts            # Wrong positions
└── coordinationRate             # coordinationMoves / totalMoves
```

Research findings:
- **Typically developing children (EC mode)**: ~39% coordination moves
- **Children with ASD (EC mode)**: ~54% coordination moves
  - Indicates higher need for negotiation and coordination during collaborative activity

### 4. **Interaction Workflow**

**Selection Phase:**
1. Player 1 taps piece → piece oscillates + orange halo (1 finger)
2. Player 2 joins touch → piece turns steady + purple halo (2 fingers)
3. Both players must maintain touch to drag

**Dragging Phase:**
1. Both drag piece together
2. Visual feedback shows active collaboration (purple border)
3. Coordination tracking updated

**Placement Phase:**
1. Released in solution area
2. Within correct cell → Green halo + beep ✅
3. Wrong position → Red halo + buzz, piece bounces back ❌

**Completion:**
- Final piece placed → Victory animation + music
- Shows total stats: moves, negotiations, completion time

### 5. **Visual Feedback System**

| State | Border | Halo | Sound | Behavior |
|-------|--------|------|-------|----------|
| Idle | Gray | None | - | Static |
| 1 Finger | Orange | Orange | Vibration | Oscillates |
| 2 Fingers | Purple | Purple | - | Ready to drag |
| Correct Placement | Green | Green | Beep | Anchors to grid |
| Incorrect Placement | Red | Red | Buzz | Bounces back |
| Placed (Complete) | Green | Green | - | Static, grayed out |

### 6. **UI Components**

**Game Board Zones:**

```
┌────────────────────────────────┐
│    Target Picture Area         │ (150px height)
│  (Shows completed puzzle)       │
├────────────────────────────────┤
│                                │
│  Puzzle Pieces Scatter Area    │ (180px height)
│  (Where pieces start)           │
│                                │
├────────────────────────────────┤
│  Solution Area                 │ (150px height)
│  (Target placement zone)        │ Green border
└────────────────────────────────┘

+ Progress Bar + Stat Panel
```

## Games Features

### Puzzle Types (Hardcoded - Expandable)

1. **Landscape** (8 pieces)
2. **Animal Friends** (12 pieces)

Each puzzle can be extended with:
- Different image sources
- Variable difficulty levels (4-16 pieces)
- Timed modes
- Scoring multipliers

### Statistics Page

After completion, displays:
- ✅ Total moves made
- 🤝 Coordination moves (negotiation count)
- ⏱️ Completion time
- 📊 Coordination rate (%)

## Research-Based Design Decisions

### ✅ Why Enforced Collaboration Works

From Study 2 (16 boys with ASD):

1. **Increased Simultaneous Activity**
   - EC mode: 67% simultaneous activity
   - Free Play: 13% simultaneous activity
   - **Result**: Children spent 2/3 of time working together

2. **Higher Coordination Moves**
   - EC mode: 64 coordination moves avg
   - Free Play: 7 coordination moves avg
   - **Insight**: ASD children show higher need for negotiation

3. **Preserved Task Performance**
   - Similar functional moves between modes
   - Performance not degraded by EC constraints
   - **Conclusion**: Enforced rules don't harm problem-solving

4. **Well Tolerated**
   - No withdrawal or discomfort reported
   - Children persisted to puzzle completion
   - Visual/auditory feedback clearly understood

## Implementation Notes

### Multi-Touch Handling

Uses Flutter's `GestureDetector` with `onPanStart`/`onPanUpdate`/`onPanEnd` events.

**Limitation**: Single GestureDetector tracks one pointer. For true multi-touch (2 independent fingers on same piece):
- **Enhancement**: Use `Listener` widget with pointer tracking
- Would allow simultaneous 2-finger detection on android/iOS

### Sound & Animation

Currently implemented as placeholders:
- `_playOscillationAnimation()` - Visual only
- `_playSuccessAnimation()` - Ready for sound package
- `_playErrorAnimation()` - Ready for haptic feedback

**Enhancement**: Integrate:
- `audioplayers` package for sounds
- `haptic_feedback` for vibration
- `flutter_animate` for sophisticated animations

## Future Enhancements

1. **Joint Attention Variants**
   - Players must point in same direction
   - Track gaze convergence

2. **Emotion Recognition Integration**
   - Pieces show emotional expressions
   - Must match correct emotions

3. **Real-Time Collaboration Analytics**
   - Live graphing of moves over time
   - Heat maps of interaction patterns

4. **Adaptive Difficulty**
   - Adjust piece count based on performance
   - Progressive challenges

5. **Network Multiplayer**
   - Different devices playing together
   - Remote collaborative puzzle solving

## Files Structure

```
lib/app/modules/game/modules/collaborative_puzzle_game/
├── models/
│   └── puzzle_model.dart          # Data structures
├── controllers/
│   └── collaborative_puzzle_game_controller.dart  # Game logic
├── views/
│   └── collaborative_puzzle_game_view.dart        # UI
├── widgets/
│   └── puzzle_piece_widget.dart    # Piece rendering
└── bindings/
    └── collaborative_puzzle_game_binding.dart     # Dependency injection
```

## Testing Recommendations

1. **Multi-touch Simulation** 
   - Test with multiple fingers on same piece
   - Verify finger tracking per piece

2. **Placement Detection**
   - Test edge cases of solution area boundaries
   - Verify grid snapping accuracy

3. **Feedback Timing**
   - Ensure animations play when expected
   - Sound plays for correct/incorrect placement

4. **Performance**
   - Test with 16+ pieces
   - Monitor frame rate during complex interactions

## References

- Battocchi, A., Pianesi, F., et al. (2009). "Collaborative Puzzle Game: a Tabletop Interactive Game for Fostering Collaboration in Children with Autism Spectrum Disorders (ASD)". ITS 2009.
- Study 1: 70 typically developing children (Collaborative vs Free Play modes)
- Study 2: 16 children with ASD (within-subjects design)

## Key Metrics from Research

| Metric | FP Mode | EC Mode | Significance |
|--------|---------|---------|--------------|
| Completion Time | 206s | 512s | EC ~2.5x longer |
| Total Moves | 39 | 102 | EC requires more moves |
| Coordination Moves Rate | 39% | 38% | Proportional increase |
| Simultaneous Activity | 4% | 83% | EC forces collaboration |
| For ASD - Coordination Rate | 23% | 54% | ASD children need more negotiation |

This implementation brings research-backed collaborative training to mobile platforms! 🎮✅
