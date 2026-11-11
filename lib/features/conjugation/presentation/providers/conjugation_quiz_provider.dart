import 'dart:async';
import 'dart:math';

import 'package:jerevise/core/utils/audio_service.dart';
import 'package:jerevise/features/conjugation/data/datasources/verb_json_datasource.dart';
import 'package:jerevise/features/conjugation/domain/entities/conjugation_constants.dart';
import 'package:jerevise/features/conjugation/domain/entities/quiz_config.dart';
import 'package:jerevise/features/conjugation/domain/entities/quiz_question.dart';
import 'package:jerevise/features/conjugation/domain/entities/quiz_state.dart';
import 'package:jerevise/features/conjugation/domain/entities/verb.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conjugation_quiz_provider.g.dart';

/// Quiz game provider — family parameterised by [QuizConfig].
///
/// Converts the original Conjugo [QuizNotifier] (StateNotifier) to the
/// @riverpod code-gen pattern used throughout this project.
@riverpod
class ConjugationQuiz extends _$ConjugationQuiz {
  Timer? _timer;
  final Random _random = Random();
  bool _disposed = false;

  // ------------------------------------------------------------------
  // build — loads verbs, generates questions, starts first timer
  // ------------------------------------------------------------------
  @override
  QuizState build(QuizConfig config) {
    _disposed = false;
    // Ensure timer is cancelled when provider is disposed (e.g. on pop)
    ref.onDispose(() {
      _timer?.cancel();
      _disposed = true;
    });

    // Load verbs synchronously from the datasource cache.
    // The datasource exposes a synchronous getter after the first async load;
    // we call the async path via a fire-and-forget so that the very first
    // access populates the cache, then we rebuild once the verbs are ready.
    final datasource = ref.read(verbJsonDatasourceProvider);
    final cachedVerbs = datasource.cachedVerbs;

    if (cachedVerbs == null) {
      // Cache not yet warm — trigger async load and return empty state.
      // The datasource will complete, provider will rebuild via invalidation.
      _initAsync(config);
      return const QuizState(questions: []);
    }

    return _initFromVerbs(cachedVerbs, config);
  }

  // ------------------------------------------------------------------
  // Private helpers
  // ------------------------------------------------------------------

  /// Async path: waits for the datasource to load, then replaces state.
  Future<void> _initAsync(QuizConfig config) async {
    final datasource = ref.read(verbJsonDatasourceProvider);
    final allVerbs = await datasource.getAll();
    if (_disposed) return;

    // Filter to the verbs selected by the user (by infinitive).
    final pool = config.selectedVerbs.isEmpty
        ? allVerbs
        : allVerbs
            .where((v) => config.selectedVerbs.contains(v.infinitive))
            .toList();

    if (pool.isEmpty) return;

    state = _initFromVerbs(pool, config);
  }

  /// Builds the full initial [QuizState] from a verb pool and starts timer.
  QuizState _initFromVerbs(List<Verb> allVerbs, QuizConfig config) {
    final pool = config.selectedVerbs.isEmpty
        ? allVerbs
        : allVerbs
            .where((v) => config.selectedVerbs.contains(v.infinitive))
            .toList();

    if (pool.isEmpty) {
      return const QuizState(questions: []);
    }

    final questions = _buildQuestions(pool, config.numberQuestions);
    final initialState = QuizState(
      questions: questions,
      index: 0,
      score: 0,
      timeRemaining: config.timeLimit,
      showFeedback: false,
      lastCorrect: false,
    );

    // Schedule timer start after the current frame so that state is set first.
    Future.microtask(() {
      if (!_disposed) _startTimer(config.timeLimit);
    });

    return initialState;
  }

  /// Builds [count] quiz questions by sampling randomly from [pool].
  List<QuizQuestion> _buildQuestions(List<Verb> pool, int count) {
    final questions = <QuizQuestion>[];

    for (var i = 0; i < count; i++) {
      final verb = pool[_random.nextInt(pool.length)];
      final subject = ConjugationConstants
          .subjects[_random.nextInt(ConjugationConstants.subjects.length)];
      final correct = verb.present[subject]!;

      // Collect distractors: other forms of the same verb first,
      // then the same subject from other verbs in the pool.
      final opts = <String>{correct};

      // Same verb, other subjects
      for (final s in ConjugationConstants.subjects) {
        if (opts.length >= 4) break;
        final form = verb.present[s];
        if (form != null) opts.add(form);
      }

      // Other verbs, same subject
      for (final v in pool) {
        if (opts.length >= 4) break;
        final form = v.present[subject];
        if (form != null) opts.add(form);
      }

      final options = opts.toList()..shuffle(_random);

      questions.add(QuizQuestion(
        id: i,
        verb: verb,
        subject: subject,
        correct: correct,
        options: List.unmodifiable(options),
      ),);
    }

    return questions;
  }

  /// Starts (or restarts) the countdown timer for the current question.
  void _startTimer(int seconds) {
    _timer?.cancel();
    state = state.copyWith(timeRemaining: seconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_disposed) {
        _timer?.cancel();
        return;
      }
      if (state.timeRemaining <= 1) {
        // Time is up — count as wrong answer
        answer(null);
      } else {
        state = state.copyWith(timeRemaining: state.timeRemaining - 1);
      }
    });
  }

  // ------------------------------------------------------------------
  // Public API
  // ------------------------------------------------------------------

  /// Records the user's [choice] for the current question.
  ///
  /// Pass `null` to indicate a timeout (counts as wrong).
  void answer(String? choice) {
    _timer?.cancel();
    if (state.questions.isEmpty) return;

    final q = state.questions[state.index];
    final ok = choice != null && choice == q.correct;

    // Play feedback sound (fire-and-forget)
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

  /// Advances to the next question, or does nothing if on the last one.
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

  // ------------------------------------------------------------------
  // Computed getters
  // ------------------------------------------------------------------

  /// Whether the quiz has reached the last question and feedback is shown.
  bool get isFinished =>
      state.questions.isNotEmpty &&
      state.index >= state.questions.length - 1 &&
      state.showFeedback;

  /// Current question or `null` if the state is not yet initialised.
  QuizQuestion? get currentQuestion =>
      state.questions.isEmpty ? null : state.questions[state.index];
}
