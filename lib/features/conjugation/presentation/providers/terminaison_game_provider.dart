import 'dart:async';
import 'dart:math';

import 'package:jerevise/core/utils/audio_service.dart';
import 'package:jerevise/features/conjugation/data/datasources/verb_builder_json_datasource.dart';
import 'package:jerevise/features/conjugation/domain/entities/conjugation_constants.dart';
import 'package:jerevise/features/conjugation/domain/entities/quiz_config.dart';
import 'package:jerevise/features/conjugation/domain/entities/terminaison_question.dart';
import 'package:jerevise/features/conjugation/domain/entities/terminaison_state.dart';
import 'package:jerevise/features/conjugation/domain/entities/verb_builder_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'terminaison_game_provider.g.dart';

@riverpod
class TerminaisonGame extends _$TerminaisonGame {
  Timer? _timer;
  final Random _random = Random();
  bool _disposed = false;

  @override
  TerminaisonState build(QuizConfig config) {
    _disposed = false;
    ref.onDispose(() {
      _timer?.cancel();
      _disposed = true;
    });

    final datasource = ref.read(verbBuilderJsonDatasourceProvider);
    final cached = datasource.cachedVerbs;

    if (cached == null) {
      _initAsync(config);
      return const TerminaisonState();
    }

    return _initFromVerbs(cached, config);
  }

  Future<void> _initAsync(QuizConfig config) async {
    final datasource = ref.read(verbBuilderJsonDatasourceProvider);
    final all = await datasource.getAll();
    if (_disposed) return;

    final pool = config.selectedVerbs.isEmpty
        ? all
        : all.where((v) => config.selectedVerbs.contains(v.infinitif)).toList();
    if (pool.isEmpty) return;

    state = _initFromVerbs(pool, config);
  }

  TerminaisonState _initFromVerbs(
      List<VerbBuilderData> allVerbs, QuizConfig config,) {
    final pool = config.selectedVerbs.isEmpty
        ? allVerbs
        : allVerbs
            .where((v) => config.selectedVerbs.contains(v.infinitif))
            .toList();
    if (pool.isEmpty) return const TerminaisonState();

    final questions = _buildQuestions(pool, config.numberQuestions);
    final st = TerminaisonState(
      questions: questions,
      index: 0,
      score: 0,
      timeRemaining: config.timeLimit,
      showFeedback: false,
      lastCorrect: false,
    );

    Future.microtask(() {
      if (!_disposed) _startTimer(config.timeLimit);
    });

    return st;
  }

  List<TerminaisonQuestion> _buildQuestions(
      List<VerbBuilderData> pool, int count,) {
    final questions = <TerminaisonQuestion>[];

    // Collect all unique terminaisons from the pool for distractors.
    final allTerminaisons = <String>{};
    for (final v in pool) {
      for (final cp in v.present.values) {
        allTerminaisons.add(cp.terminaison);
      }
    }
    final terminaisonList = allTerminaisons.toList();

    for (var i = 0; i < count; i++) {
      final verb = pool[_random.nextInt(pool.length)];
      final subject = ConjugationConstants
          .subjects[_random.nextInt(ConjugationConstants.subjects.length)];
      final parts = verb.present[subject]!;

      final opts = <String>{parts.terminaison};

      // Same verb, other subjects
      for (final s in ConjugationConstants.subjects) {
        if (opts.length >= 4) break;
        final cp = verb.present[s];
        if (cp != null && cp.terminaison != parts.terminaison) {
          opts.add(cp.terminaison);
        }
      }

      // Fill from global pool
      final shuffled = List.of(terminaisonList)..shuffle(_random);
      for (final t in shuffled) {
        if (opts.length >= 4) break;
        opts.add(t);
      }

      final options = opts.toList()..shuffle(_random);

      questions.add(TerminaisonQuestion(
        id: i,
        verb: verb,
        subject: subject,
        radical: parts.radical,
        correctTerminaison: parts.terminaison,
        options: List.unmodifiable(options),
      ),);
    }

    return questions;
  }

  void _startTimer(int seconds) {
    _timer?.cancel();
    state = state.copyWith(timeRemaining: seconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_disposed) {
        _timer?.cancel();
        return;
      }
      if (state.timeRemaining <= 1) {
        answer(null);
      } else {
        state = state.copyWith(timeRemaining: state.timeRemaining - 1);
      }
    });
  }

  void answer(String? choice) {
    _timer?.cancel();
    if (state.questions.isEmpty) return;

    final q = state.questions[state.index];
    final ok = choice != null && choice == q.correctTerminaison;

    final audio = ref.read(audioServiceProvider);
    if (ok) {
      audio.playSuccess();
    } else {
      audio.playError();
    }

    state = state.copyWith(
      score: state.score + (ok ? 1 : 0),
      showFeedback: true,
      lastCorrect: ok,
    );
  }

  void next() {
    if (state.questions.isEmpty) return;
    final isLast = state.index >= state.questions.length - 1;
    if (isLast) {
      _timer?.cancel();
      return;
    }

    state = state.copyWith(
      index: state.index + 1,
      showFeedback: false,
      lastCorrect: false,
    );

    _startTimer(config.timeLimit);
  }

  bool get isFinished =>
      state.questions.isNotEmpty &&
      state.index >= state.questions.length - 1 &&
      state.showFeedback;
}
