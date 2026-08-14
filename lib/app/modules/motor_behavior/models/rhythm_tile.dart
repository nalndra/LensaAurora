import 'dart:math';

/// The three interaction modes the falling tiles test:
/// - [tap]: a plain square — tap it once as it crosses the hit line.
/// - [hold]: an elongated bar — press and hold for its whole length.
/// - [trace]: a zigzag bar — press, hold, *and* keep your finger tracking
///   the zigzag's left-right motion as it falls.
enum TileType { tap, hold, trace }

enum TileResult { pending, perfect, good, miss }

/// A single falling tile. Positions are computed on demand from
/// [MotorRhythmSession.fallSpeedPxPerMs] rather than stored, so the whole
/// board only needs one clock (elapsed time since the tile spawned).
class RhythmTile {
  RhythmTile({
    required this.id,
    required this.lane,
    required this.type,
    required this.spawnTime,
    required this.fallSpeedPxPerMs,
    required this.hitLineY,
    this.holdDurationMs = 0,
  }) : zigzagPoints = type == TileType.trace
           ? _buildZigzag(Random(id.hashCode))
           : const [];

  final int id;
  final int lane;
  final TileType type;
  final DateTime spawnTime;
  final double fallSpeedPxPerMs;
  final double hitLineY;

  /// How long (ms) a hold/trace tile must be held for. Zero for tap tiles.
  final int holdDurationMs;

  /// Normalized (fraction of duration -> x offset in [-1, 1]) waypoints
  /// describing the zigzag path for trace tiles.
  final List<Point<double>> zigzagPoints;

  TileResult result = TileResult.pending;
  bool isHeld = false;
  DateTime? holdStartedAt;

  /// Accumulated tracking error while holding a trace tile (sum of
  /// |actual - expected| offsets, sampled each frame) and sample count,
  /// used to compute a final tracing accuracy once released.
  double traceErrorSum = 0;
  int traceSampleCount = 0;

  static const double baseHeight = 60;

  double get heightPx => holdDurationMs > 0
      ? baseHeight + holdDurationMs * fallSpeedPxPerMs
      : baseHeight;

  /// Top edge Y position (px, board-local) at [elapsedMs] since spawn.
  double topY(int elapsedMs) => elapsedMs * fallSpeedPxPerMs - heightPx;

  /// Elapsed ms (since spawn) at which the tile's actionable window
  /// begins — i.e. when it reaches the hit line.
  int get windowStartMs => ((hitLineY + heightPx) / fallSpeedPxPerMs).round();

  /// For tap tiles: the single ideal instant (tile center on hit line).
  int get idealTapMs => ((hitLineY + heightPx / 2) / fallSpeedPxPerMs).round();

  /// For hold/trace tiles: when the required hold is over.
  int get windowEndMs => windowStartMs + holdDurationMs;

  /// How far past its window a tile can go before being auto-missed.
  static const int missGraceMs = 450;

  bool isExpired(int elapsedMs) {
    final deadline = type == TileType.tap ? idealTapMs : windowEndMs;
    return elapsedMs > deadline + missGraceMs && result == TileResult.pending;
  }

  /// Expected lateral offset (px from lane center) for a trace tile at a
  /// given progress fraction (0..1) through its hold window.
  double expectedTraceOffset(double progress, double laneWidth) {
    if (zigzagPoints.isEmpty) return 0;
    final clamped = progress.clamp(0.0, 1.0);
    for (var i = 0; i < zigzagPoints.length - 1; i++) {
      final a = zigzagPoints[i];
      final b = zigzagPoints[i + 1];
      if (clamped >= a.x && clamped <= b.x) {
        final segmentT = (b.x - a.x) == 0 ? 0.0 : (clamped - a.x) / (b.x - a.x);
        final normalized = a.y + (b.y - a.y) * segmentT;
        return normalized * (laneWidth / 2 - 24);
      }
    }
    return zigzagPoints.last.y * (laneWidth / 2 - 24);
  }

  static List<Point<double>> _buildZigzag(Random rng) {
    // 4-6 waypoints alternating left/right so the path visibly zigzags.
    final segments = 4 + rng.nextInt(3);
    final points = <Point<double>>[];
    for (var i = 0; i <= segments; i++) {
      final x = i / segments;
      final y = i.isEven ? -0.8 : 0.8;
      points.add(Point(x, y * (0.7 + rng.nextDouble() * 0.3)));
    }
    return points;
  }
}
