import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerevise/core/constants/app_colors.dart';
import 'package:jerevise/core/constants/app_dimensions.dart';
import 'package:jerevise/core/constants/app_typography.dart';
import 'package:jerevise/features/conjugation/data/datasources/verb_json_datasource.dart';
import 'package:jerevise/features/conjugation/domain/entities/conjugation_constants.dart';
import 'package:jerevise/features/conjugation/domain/entities/quiz_config.dart';
import 'package:jerevise/features/conjugation/domain/entities/verb.dart';
import 'package:jerevise/features/conjugation/presentation/screens/quiz_game_screen.dart';
import 'package:jerevise/shared/widgets/app_header.dart';
import 'package:jerevise/shared/widgets/back_button.dart';
import 'package:jerevise/shared/widgets/colorful_button.dart';
import 'package:jerevise/shared/widgets/gradient_background.dart';

class QuizSetupScreen extends ConsumerStatefulWidget {
  final QuizConfig? previousConfig;

  const QuizSetupScreen({super.key, this.previousConfig});

  @override
  ConsumerState<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends ConsumerState<QuizSetupScreen> {
  Map<String, List<Verb>> _verbsByGroup = {};
  Set<String> _selectedVerbs = {};
  int _timeLimit = ConjugationConstants.defaultTimeLimit;
  int _questionCount = ConjugationConstants.defaultQuestionCount;
  bool _isLoading = true;

  static const _groupOrder = ['exception', '1', '2', '3'];

  @override
  void initState() {
    super.initState();
    _loadVerbs();
  }

  Future<void> _loadVerbs() async {
    try {
      final datasource = ref.read(verbJsonDatasourceProvider);
      final verbs = await datasource.getAll();
      final byGroup = <String, List<Verb>>{};
      for (final v in verbs) {
        byGroup.putIfAbsent(v.groupTag, () => []).add(v);
      }

      setState(() {
        _verbsByGroup = byGroup;

        if (widget.previousConfig != null) {
          _selectedVerbs = widget.previousConfig!.selectedVerbs.toSet();
          _timeLimit = widget.previousConfig!.timeLimit;
          _questionCount = widget.previousConfig!.numberQuestions;
        } else {
          final g1 = byGroup['1'] ?? [];
          _selectedVerbs = g1.take(3).map((v) => v.infinitive).toSet();
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _toggleVerb(String infinitive) {
    setState(() {
      if (_selectedVerbs.contains(infinitive)) {
        _selectedVerbs.remove(infinitive);
      } else {
        _selectedVerbs.add(infinitive);
      }
    });
  }

  void _toggleGroup(String groupTag) {
    final groupVerbs = _verbsByGroup[groupTag] ?? [];
    final infinitives = groupVerbs.map((v) => v.infinitive).toSet();
    final allSelected = infinitives.every((v) => _selectedVerbs.contains(v));
    setState(() {
      if (allSelected) {
        _selectedVerbs.removeAll(infinitives);
      } else {
        _selectedVerbs.addAll(infinitives);
      }
    });
  }

  void _startQuiz() {
    if (_selectedVerbs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionne au moins un verbe !'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final config = QuizConfig(
      selectedVerbs: _selectedVerbs.toSet(),
      timeLimit: _timeLimit,
      numberQuestions: _questionCount,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizGameScreen(config: config),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppHeader(
                title: 'Quiz Conjugaison',
                subtitle: 'CHOISIS TON DÉFI !',
                leading: BackButton3D(onTap: () => Navigator.pop(context)),
              ),

              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.textOnColor),
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                    ),
                    children: [
                      const SizedBox(height: AppDimensions.spacingM),

                      // Selected count badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingM,
                          vertical: AppDimensions.paddingS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.textOnColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_stories, color: AppColors.textOnColor, size: 18),
                            const SizedBox(width: AppDimensions.spacingS),
                            Text(
                              '${_selectedVerbs.length} verbes sélectionnés',
                              style: const TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: AppTypography.bodyMedium,
                                fontWeight: AppTypography.semiBold,
                                color: AppColors.textOnColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingXl),

                      // Section title — verbs
                      const Text(
                        'CHOISIS TES VERBES',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: AppTypography.bodySmall,
                          fontWeight: AppTypography.bold,
                          color: AppColors.textOnColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingL),

                      // Verb group cards
                      ..._groupOrder.map((groupTag) {
                        final verbs = _verbsByGroup[groupTag] ?? [];
                        if (verbs.isEmpty) return const SizedBox.shrink();
                        return _VerbGroupCard(
                          groupTag: groupTag,
                          verbs: verbs,
                          selectedVerbs: _selectedVerbs,
                          onToggleGroup: () => _toggleGroup(groupTag),
                          onToggleVerb: _toggleVerb,
                        );
                      }),

                      const SizedBox(height: AppDimensions.spacingXl),

                      // Section title — settings
                      const Text(
                        'RÉGLAGES',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: AppTypography.bodySmall,
                          fontWeight: AppTypography.bold,
                          color: AppColors.textOnColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingL),

                      // Time + Questions in a single card
                      _SettingsCard(
                        timeLimit: _timeLimit,
                        questionCount: _questionCount,
                        onTimeChanged: (t) => setState(() => _timeLimit = t),
                        onCountChanged: (c) => setState(() => _questionCount = c),
                      ),

                      const SizedBox(height: AppDimensions.spacingXxl),

                      // Start button
                      ColorfulButton(
                        text: _selectedVerbs.isEmpty
                            ? 'SÉLECTIONNE DES VERBES'
                            : 'C\'EST PARTI !',
                        icon: Icons.play_arrow,
                        color: AppColors.success,
                        shadowColor: AppColors.successShadow,
                        onTap: _selectedVerbs.isEmpty ? null : _startQuiz,
                        width: double.infinity,
                      ),

                      const SizedBox(height: AppDimensions.spacingXxl),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Colorful card for a verb group — same style as LevelCard
class _VerbGroupCard extends StatefulWidget {
  final String groupTag;
  final List<Verb> verbs;
  final Set<String> selectedVerbs;
  final VoidCallback onToggleGroup;
  final void Function(String) onToggleVerb;

  const _VerbGroupCard({
    required this.groupTag,
    required this.verbs,
    required this.selectedVerbs,
    required this.onToggleGroup,
    required this.onToggleVerb,
  });

  @override
  State<_VerbGroupCard> createState() => _VerbGroupCardState();
}

class _VerbGroupCardState extends State<_VerbGroupCard> {
  bool _expanded = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final meta = ConjugationConstants.groupMetadata[widget.groupTag]!;
    final groupColor = meta['color'] as Color;
    final groupName = meta['name'] as String;
    final groupIcon = meta['icon'] as IconData;
    final description = meta['description'] as String;
    final infinitives = widget.verbs.map((v) => v.infinitive).toSet();
    final selectedCount = infinitives.where((v) => widget.selectedVerbs.contains(v)).length;
    final allSelected = selectedCount == infinitives.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingL),
      child: Column(
        children: [
          // Group header card — like LevelCard
          GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) {
              setState(() {
                _isPressed = false;
                _expanded = !_expanded;
              });
            },
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              transform: Matrix4.translationValues(0, _isPressed ? 3 : 0, 0),
              decoration: BoxDecoration(
                color: allSelected ? groupColor : AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
                boxShadow: [
                  BoxShadow(
                    color: allSelected
                        ? groupColor.withValues(alpha: 0.6)
                        : AppColors.primaryDark,
                    blurRadius: 0,
                    offset: Offset(0, _isPressed ? 3 : 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon badge
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: allSelected
                          ? AppColors.textOnColor.withValues(alpha: 0.25)
                          : groupColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    child: Center(
                      child: Icon(
                        groupIcon,
                        size: 28,
                        color: allSelected ? AppColors.textOnColor : groupColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingM),

                  // Title + description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          groupName,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: AppTypography.headingSmall,
                            fontWeight: AppTypography.bold,
                            color: allSelected
                                ? AppColors.textOnColor
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          description,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: AppTypography.bodySmall,
                            fontWeight: AppTypography.semiBold,
                            color: allSelected
                                ? AppColors.textOnColor.withValues(alpha: 0.85)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Count badge + expand arrow
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingS,
                      vertical: AppDimensions.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: allSelected
                          ? AppColors.textOnColor.withValues(alpha: 0.25)
                          : groupColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Text(
                      '$selectedCount/${infinitives.length}',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: AppTypography.bodySmall,
                        fontWeight: AppTypography.bold,
                        color: allSelected ? AppColors.textOnColor : groupColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: allSelected ? AppColors.textOnColor : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Expanded verb chips
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(
                top: AppDimensions.spacingS,
                left: AppDimensions.spacingS,
                right: AppDimensions.spacingS,
              ),
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.primaryDark,
                    blurRadius: 0,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Select all / none toggle
                  GestureDetector(
                    onTap: widget.onToggleGroup,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                        vertical: AppDimensions.spacingS,
                      ),
                      decoration: BoxDecoration(
                        color: allSelected
                            ? groupColor.withValues(alpha: 0.15)
                            : AppColors.borderLight,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        border: Border.all(
                          color: allSelected ? groupColor : AppColors.textLight,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            allSelected ? Icons.check_circle : Icons.circle_outlined,
                            color: allSelected ? groupColor : AppColors.textLight,
                            size: AppDimensions.iconM,
                          ),
                          const SizedBox(width: AppDimensions.spacingS),
                          Text(
                            allSelected ? 'Tout désélectionner' : 'Tout sélectionner',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: AppTypography.bodyMedium,
                              fontWeight: AppTypography.semiBold,
                              color: allSelected ? groupColor : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingL),

                  // Verb chips
                  Wrap(
                    spacing: AppDimensions.spacingS,
                    runSpacing: AppDimensions.spacingS,
                    children: widget.verbs.map((verb) {
                      final isSelected = widget.selectedVerbs.contains(verb.infinitive);
                      return _VerbChip(
                        text: verb.infinitive,
                        isSelected: isSelected,
                        color: groupColor,
                        onTap: () => widget.onToggleVerb(verb.infinitive),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Verb chip with 3D press effect
class _VerbChip extends StatefulWidget {
  final String text;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _VerbChip({
    required this.text,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  State<_VerbChip> createState() => _VerbChipState();
}

class _VerbChipState extends State<_VerbChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.spacingS,
        ),
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        decoration: BoxDecoration(
          color: widget.isSelected ? widget.color : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(
              color: widget.isSelected
                  ? widget.color.withValues(alpha: 0.5)
                  : AppColors.shadowColor,
              blurRadius: 0,
              offset: Offset(0, _isPressed ? 1 : 3),
            ),
          ],
          border: widget.isSelected
              ? null
              : Border.all(color: AppColors.borderLight, width: 1.5),
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.bodyMedium,
            fontWeight: AppTypography.semiBold,
            color: widget.isSelected
                ? AppColors.textOnColor
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Settings card with time + question count — colorful pill buttons
class _SettingsCard extends StatelessWidget {
  final int timeLimit;
  final int questionCount;
  final ValueChanged<int> onTimeChanged;
  final ValueChanged<int> onCountChanged;

  const _SettingsCard({
    required this.timeLimit,
    required this.questionCount,
    required this.onTimeChanged,
    required this.onCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        boxShadow: const [
          BoxShadow(
            color: AppColors.primaryDark,
            blurRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time limit
          const Row(
            children: [
              Icon(Icons.timer, color: AppColors.buttonBlue, size: 22),
              SizedBox(width: AppDimensions.spacingS),
              Text(
                'TEMPS DE RÉPONSE',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: AppTypography.bodySmall,
                  fontWeight: AppTypography.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Wrap(
            spacing: AppDimensions.spacingS,
            runSpacing: AppDimensions.spacingS,
            children: ConjugationConstants.timeLimits.map((time) {
              return _OptionPill(
                text: '${time}s',
                isSelected: timeLimit == time,
                color: AppColors.buttonBlue,
                shadowColor: AppColors.buttonBlueShadow,
                onTap: () => onTimeChanged(time),
              );
            }).toList(),
          ),

          const SizedBox(height: AppDimensions.spacingXl),
          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: AppDimensions.spacingXl),

          // Question count
          const Row(
            children: [
              Icon(Icons.quiz, color: AppColors.buttonOrange, size: 22),
              SizedBox(width: AppDimensions.spacingS),
              Text(
                'NOMBRE DE QUESTIONS',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: AppTypography.bodySmall,
                  fontWeight: AppTypography.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Wrap(
            spacing: AppDimensions.spacingS,
            runSpacing: AppDimensions.spacingS,
            children: ConjugationConstants.questionCounts.map((count) {
              return _OptionPill(
                text: '$count',
                isSelected: questionCount == count,
                color: AppColors.buttonOrange,
                shadowColor: AppColors.buttonOrangeShadow,
                onTap: () => onCountChanged(count),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Option pill button with 3D press effect
class _OptionPill extends StatefulWidget {
  final String text;
  final bool isSelected;
  final Color color;
  final Color shadowColor;
  final VoidCallback onTap;

  const _OptionPill({
    required this.text,
    required this.isSelected,
    required this.color,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  State<_OptionPill> createState() => _OptionPillState();
}

class _OptionPillState extends State<_OptionPill> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingS + 2,
        ),
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        decoration: BoxDecoration(
          color: widget.isSelected ? widget.color : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(
              color: widget.isSelected ? widget.shadowColor : AppColors.shadowColor,
              blurRadius: 0,
              offset: Offset(0, _isPressed ? 2 : 4),
            ),
          ],
          border: widget.isSelected
              ? null
              : Border.all(color: AppColors.borderLight, width: 1.5),
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.bodyLarge,
            fontWeight: AppTypography.bold,
            color: widget.isSelected
                ? AppColors.textOnColor
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
