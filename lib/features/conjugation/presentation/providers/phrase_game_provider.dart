import 'dart:async';
import 'dart:math';

import 'package:jerevise/core/utils/audio_service.dart';
import 'package:jerevise/features/conjugation/data/datasources/verb_json_datasource.dart';
import 'package:jerevise/features/conjugation/domain/entities/conjugation_constants.dart';
import 'package:jerevise/features/conjugation/domain/entities/phrase_question.dart';
import 'package:jerevise/features/conjugation/domain/entities/phrase_state.dart';
import 'package:jerevise/features/conjugation/domain/entities/quiz_config.dart';
import 'package:jerevise/features/conjugation/domain/entities/sentence_templates.dart';
import 'package:jerevise/features/conjugation/domain/entities/verb.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'phrase_game_provider.g.dart';

@riverpod
class PhraseGame extends _$PhraseGame {
  Timer? _timer;
  final Random _random = Random();
  bool _disposed = false;

  @override
  PhraseState build(QuizConfig config) {
    _disposed = false;
    ref.onDispose(() {
      _timer?.cancel();
      _disposed = true;
    });

    final datasource = ref.read(verbJsonDatasourceProvider);
    final cached = datasource.cachedVerbs;

    if (cached == null) {
      _initAsync(config);
      return const PhraseState();
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

  PhraseState _initFromVerbs(List<Verb> allVerbs, QuizConfig config) {
    final pool = _filterPool(allVerbs, config);
    if (pool.isEmpty) return const PhraseState();

    final questions = _buildQuestions(pool, config.numberQuestions);
    final st = PhraseState(
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

  List<PhraseQuestion> _buildQuestions(List<Verb> pool, int count) {
    final questions = <PhraseQuestion>[];

    for (var i = 0; i < count; i++) {
      final verb = pool[_random.nextInt(pool.length)];
      final subject = ConjugationConstants
          .subjects[_random.nextInt(ConjugationConstants.subjects.length)];
      final correct = verb.present[subject]!;

      // Pick a random sentence template for this subject.
      final templates = sentenceTemplates[subject] ?? ['___ .'];
      final template = templates[_random.nextInt(templates.length)];
      final displaySentence = template.replaceAll('___', '________');

      // Build options
      final opts = <String>{correct};

      for (final s in ConjugationConstants.subjects) {
        if (opts.length >= 4) break;
        final form = verb.present[s];
        if (form != null) opts.add(form);
      }

      for (final v in pool) {
        if (opts.length >= 4) break;
        final form = v.present[subject];
        if (form != null) opts.add(form);
      }

      final options = opts.toList()..shuffle(_random);

      questions.add(PhraseQuestion(
        id: i,
        verb: verb,
        subject: subject,
        correct: correct,
        options: List.unmodifiable(options),
        displaySentence: displaySentence,
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
    final ok = choice != null && choice == q.correct;

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
