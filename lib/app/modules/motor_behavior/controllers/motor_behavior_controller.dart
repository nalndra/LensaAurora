import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/routes/app_pages.dart';
import 'package:lensaaurora/app/services/gaze_results_service.dart';
import '../models/rhythm_tile.dart';

enum MotorTestState { menu, playing, completed }

class MotorBehaviorController extends GetxController {
  final testState = MotorTestState.menu.obs;

  static const int laneCount = 3;
  static const int totalTiles = 16;
  static const int _travelDurationMs = 2200;

  final activeTiles = <RhythmTile>[].obs;
  final tilesSpawned = 0.obs;
  final tilesResolved = 0.obs;
  final comboCount = 0.obs;
  final scoreSum = 0.0.obs; // sum of per-tile scores (0-100 each)

  // Per-type breakdown, shown on the results screen.
  final tapScores = <double>[];
  final holdScores = <double>[];
  final traceScores = <double>[];

  double _boardWidth = 0;
  double _boardHeight = 0;
  double _hitLineY = 0;
  double _fallSpeedPxPerMs = 0;
  double get hitLineY => _hitLineY;
  double get laneWidth => _boardWidth / laneCount;

  Timer? _ticker;
  DateTime? _gameStart;
  int _nextId = 0;
  int _nextSpawnAtMs = 0;
  final _rng = Random();
  final Map<int, double> _pointerLocalX = {};
  DateTime? _testStartTime;

  final _resultsService = GazeResultsService();

  /// Called once the game board's actual on-screen size is known.
  void configureBoard(double width, double height) {
    if (_boardWidth == width && _boardHeight == height) return;
    _boardWidth = width;
    _boardHeight = height;
    _hitLineY = height * 0.76;
    _fallSpeedPxPerMs = _hitLineY / _travelDurationMs;
  }

  void startGame() {
    activeTiles.clear();
    tapScores.clear();
    holdScores.clear();
    traceScores.clear();
    tilesSpawned.value = 0;
    tilesResolved.value = 0;
    comboCount.value = 0;
    scoreSum.value = 0;
    _nextId = 0;
    _gameStart = DateTime.now();
    _testStartTime = _gameStart;
    _nextSpawnAtMs = 300;
    testState.value = MotorTestState.playing;

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
  }

  int get elapsedMs => _gameStart == null
      ? 0
      : DateTime.now().difference(_gameStart!).inMilliseconds;
  int get _elapsedMs => elapsedMs;

  void _tick() {
    final elapsed = _elapsedMs;

    if (tilesSpawned.value < totalTiles && elapsed >= _nextSpawnAtMs) {
      _spawnTile(elapsed);
    }

    // Sample tracing error for any currently-held trace tile.
    for (final tile in activeTiles) {
      if (tile.type == TileType.trace && tile.isHeld) {
        final x = _pointerLocalX[tile.lane];
        if (x != null) {
          final progress =
              (elapsed - tile.windowStartMs) / max(1, tile.holdDurationMs);
          final expected = tile.expectedTraceOffset(progress, laneWidth);
          final laneCenter = laneWidth * (tile.lane + 0.5);
          final actualOffset = x - laneCenter;
          tile.traceErrorSum += (actualOffset - expected).abs();
          tile.traceSampleCount++;
        }
      }
    }

    // Auto-miss anything that fell past its window unresolved.
    for (final tile in activeTiles) {
      if (tile.result == TileResult.pending && tile.isExpired(elapsed)) {
        _resolveTile(tile, 0, TileResult.miss);
      }
    }

    activeTiles.removeWhere(
      (t) => t.result != TileResult.pending && elapsed - t.windowStartMs > 900,
    );
    activeTiles.refresh();

    if (tilesSpawned.value >= totalTiles &&
        activeTiles.every((t) => t.result != TileResult.pending)) {
      _finishGame();
    }
  }

  void _spawnTile(int elapsedMs) {
    final freeLanes = List.generate(laneCount, (i) => i)
        .where(
          (lane) => !activeTiles.any(
            (t) => t.lane == lane && t.result == TileResult.pending,
          ),
        )
        .toList();
    if (freeLanes.isEmpty) {
      // Try again shortly rather than skipping a slot entirely.
      _nextSpawnAtMs = elapsedMs + 150;
      return;
    }

    final lane = freeLanes[_rng.nextInt(freeLanes.length)];
    final type = TileType.values[_rng.nextInt(TileType.values.length)];
    final holdMs = switch (type) {
      TileType.tap => 0,
      TileType.hold => 700 + _rng.nextInt(500),
      TileType.trace => 1100 + _rng.nextInt(600),
    };

    activeTiles.add(
      RhythmTile(
        id: _nextId++,
        lane: lane,
        type: type,
        spawnTime: DateTime.now(),
        fallSpeedPxPerMs: _fallSpeedPxPerMs,
        hitLineY: _hitLineY,
        holdDurationMs: holdMs,
      ),
    );
    tilesSpawned.value++;
    _nextSpawnAtMs = elapsedMs + 900 + _rng.nextInt(500);
  }

  // --- Input handling -------------------------------------------------

  void onLanePointerDown(int lane, double localX) {
    _pointerLocalX[lane] = localX;
    final elapsed = _elapsedMs;

    final tile = _pendingTileInLane(lane);
    if (tile == null) return;

    if (tile.type == TileType.tap) {
      final delta = (elapsed - tile.idealTapMs).abs();
      if (delta <= 120) {
        _resolveTile(tile, 100, TileResult.perfect);
      } else if (delta <= 280) {
        _resolveTile(tile, 65, TileResult.good);
      } else if (delta <= RhythmTile.missGraceMs) {
        _resolveTile(tile, 30, TileResult.good);
      }
      // Outside grace window entirely: ignore (will auto-miss on expiry).
    } else {
      // Hold / trace: begin tracking as long as we're within a
      // reasonable window around the tile's actionable range.
      if (elapsed >= tile.windowStartMs - 250 &&
          elapsed <= tile.windowEndMs + 250) {
        tile.isHeld = true;
        tile.holdStartedAt = DateTime.now();
      }
    }
  }

  void onLanePointerMove(int lane, double localX) {
    _pointerLocalX[lane] = localX;
  }

  void onLanePointerUp(int lane) {
    final tile = activeTiles.firstWhereOrNull(
      (t) => t.lane == lane && t.result == TileResult.pending && t.isHeld,
    );
    if (tile == null) return;

    final elapsed = _elapsedMs;
    final pressStart = tile.holdStartedAt == null
        ? tile.windowStartMs
        : tile.holdStartedAt!.difference(_gameStart!).inMilliseconds;
    final overlapStart = max(pressStart, tile.windowStartMs);
    final overlapEnd = min(elapsed, tile.windowEndMs);
    final overlapMs = (overlapEnd - overlapStart).clamp(0, tile.holdDurationMs);
    final coverage = tile.holdDurationMs == 0
        ? 1.0
        : overlapMs / tile.holdDurationMs;

    double score;
    if (tile.type == TileType.hold) {
      score = (coverage * 100).clamp(0, 100);
    } else {
      final avgError = tile.traceSampleCount == 0
          ? laneWidth / 2
          : tile.traceErrorSum / tile.traceSampleCount;
      final maxError = laneWidth / 2;
      final traceAccuracy = (1 - (avgError / maxError)).clamp(0.0, 1.0) * 100;
      score = (coverage * 50) + (traceAccuracy * 0.5);
    }

    tile.isHeld = false;
    _resolveTile(
      tile,
      score,
      score >= 70
          ? TileResult.perfect
          : (score >= 35 ? TileResult.good : TileResult.miss),
    );
  }

  RhythmTile? _pendingTileInLane(int lane) => activeTiles.firstWhereOrNull(
    (t) => t.lane == lane && t.result == TileResult.pending,
  );

  void _resolveTile(RhythmTile tile, double score, TileResult result) {
    tile.result = result;
    tile.isHeld = false;
    scoreSum.value += score;
    tilesResolved.value++;
    comboCount.value = result == TileResult.miss ? 0 : comboCount.value + 1;

    switch (tile.type) {
      case TileType.tap:
        tapScores.add(score);
        break;
      case TileType.hold:
        holdScores.add(score);
        break;
      case TileType.trace:
        traceScores.add(score);
        break;
    }
    activeTiles.refresh();
  }

  Future<void> _finishGame() async {
    _ticker?.cancel();
    testState.value = MotorTestState.completed;

    final overallScore = tilesResolved.value == 0
        ? 0
        : (scoreSum.value / tilesResolved.value).round();

    try {
      await _resultsService.saveMotorResult(
        score: overallScore,
        metrics: {
          'tapAvg': _avg(tapScores),
          'holdAvg': _avg(holdScores),
          'traceAvg': _avg(traceScores),
          'tilesResolved': tilesResolved.value,
          'bestCombo': comboCount.value,
        },
        testStartTime: _testStartTime ?? DateTime.now(),
        testEndTime: DateTime.now(),
      );
    } catch (e) {
      debugPrint('[MotorBehavior] Error saving result: $e');
    }
  }

  double _avg(List<double> values) =>
      values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;

  int get overallScorePercent => tilesResolved.value == 0
      ? 0
      : (scoreSum.value / tilesResolved.value).round();

  void resetToMenu() {
    _ticker?.cancel();
    testState.value = MotorTestState.menu;
  }

  void backToScan() {
    _ticker?.cancel();
    Get.offAllNamed(Routes.SCAN);
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }
}
