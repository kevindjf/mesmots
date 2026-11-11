import 'dart:async';
import 'dart:math';

import 'package:jerevise/core/utils/audio_service.dart';
import 'package:jerevise/features/conjugation/data/datasources/verb_json_datasource.dart';
import 'package:jerevise/features/conjugation/domain/entities/quiz_config.dart';
import 'package:jerevise/features/conjugation/domain/entities/relier_round.dart';
import 'package:jerevise/features/conjugation/domain/entities/relier_state.dart';
import 'package:jerevise/features/conjugation/domain/entities/verb.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'relier_game_provider.g.dart';

@riverpod
class RelierGame extends _$RelierGame {
  final Random _random = Random();
  bool _disposed = false;
  Timer? _flashTimer;

  @override
  RelierState build(QuizConfig config) {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _flashTimer?.cancel();
    });

    final datasource = ref.read(verbJsonDatasourceProvider);
    final cached = datasource.cachedVerbs;

    if (cached == null) {
      _initAsync(config);
      return const RelierState();
    }

    return _initFromVerbs(cached, config);
  }

  Future<void> _initAsync(QuizConfig config) async {
    final datasource = ref.read(verbJsonDatasourceProvider);
    final all = await datasource.getAll();
    if (_disposed) return;

    final pool = _filterPool(all, config);
    if (pool.isEmpty) return;

    state = _initFromVerbs(pool, config);
  }

  List<Verb> _filterPool(List<Verb> all, QuizConfig config) {
    if (config.selectedVerbs.isEmpty) return all;
    return all
        .where((v) => config.selectedVerbs.contains(v.infinitive))
        .toList();
  }

  RelierState _initFromVerbs(List<Verb> allVerbs, QuizConfig config) {
    final pool = _filterPool(allVerbs, config);
    if (pool.isEmpty) return const RelierState();

    // Each round uses 4 subject-form pairs from one verb.
    // numberQuestions represents the number of rounds.
    final roundCount = config.numberQuestions;
    final rounds = <RelierRound>[];

    for (var i = 0; i < roundCount; i++) {
      final verb = pool[_random.nextInt(pool.length)];

      // Pick 4 random subjects that exist in verb.present
      final availableSubjects = verb.present.keys.toList()..shuffle(_random);
      final subjects = availableSubjects.take(4).toList();

      final pairs = <String, String>{};
      for (final s in subjects) {
        pairs[s] = verb.present[s]!;
      }

      final forms = subjects.map((s) => verb.present[s]!).toList()
        ..shuffle(_random);

      rounds.add(RelierRound(
        verb: verb,
        subjects: subjects,
        forms: forms,
        correctPairs: pairs,
      ),);
    }

    return RelierState(
      rounds: rounds,
      roundIndex: 0,
      score: 0,
      matchedSubjects: const {},
      hadErrorThisRound: false,
    );
  }

  void selectSubject(String subject) {
    if (_disposed) return;
    if (state.matchedSubjects.contains(subject)) return;

    state = state.copyWith(selectedSubject: subject);
  }

  void selectForm(String form) {
    if (_disposed) return;
    final selected = state.selectedSubject;
    if (selected == null) return;

    final round = state.currentRound;
    if (round == null) return;

    final audio = ref.read(audioServiceProvider);

    if (round.correctPairs[selected] == form) {
      // Correct match
      audio.playSuccess();
      final newMatched = {...state.matchedSubjects, selected};

      state = state.copyWith(
        matchedSubjects: newMatched,
        clearSelectedSubject: true,
      );

      // Check if all 4 matched — auto-advance after short delay
      if (newMatched.length >= round.subjects.length) {
        final earnedPoint = !state.hadErrorThisRound;
        Future.delayed(const Duration(milliseconds: 800), () {
          if (_disposed) return;
          _advanceRound(earnedPoint);
        });
      }
    } else {
      // Wrong match — flash red
      audio.playError();
      state = state.copyWith(
        flashError: form,
        hadErrorThisRound: true,
        clearSelectedSubject: true,
      );

      _flashTimer?.cancel();
      _flashTimer = Timer(const Duration(milliseconds: 500), () {
        if (_disposed) return;
        state = state.copyWith(clearFlashError: true);
      });
    }
  }

  void _advanceRound(bool earnedPoint) {
    final isLast = state.roundIndex >= state.rounds.length - 1;

    if (isLast) {
      // Game finished — keep state, screen will detect isFinished
      state = state.copyWith(
        score: state.score + (earnedPoint ? 1 : 0),
      );
      return;
    }

    state = state.copyWith(
      roundIndex: state.roundIndex + 1,
      score: state.score + (earnedPoint ? 1 : 0),
      matchedSubjects: const {},
      hadErrorThisRound: false,
      clearSelectedSubject: true,
      clearFlashError: true,
    );
  }

  bool get isFinished => state.isFinished;
}
