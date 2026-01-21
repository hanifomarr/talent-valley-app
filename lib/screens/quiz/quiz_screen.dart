import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talent_valley_app/providers/app_state.dart';
import 'package:talent_valley_app/models/models.dart';
import 'package:talent_valley_app/screens/quiz/quiz_result_screen.dart';
import 'package:talent_valley_app/theme/app_theme.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<int> _selectedAnswers = [];
  bool _showingFeedback = false;

  void _handleAnswerSelection(int index) {
    final appState = context.read<AppState>();
    final question = appState.currentQuestion;
    if (question == null || _showingFeedback) return;

    setState(() {
      if (question.type == QuestionType.multipleSelect) {
        // Multiple select: toggle selection
        if (_selectedAnswers.contains(index)) {
          _selectedAnswers.remove(index);
        } else {
          _selectedAnswers.add(index);
        }
      } else {
        // Single select
        _selectedAnswers = [index];
      }
    });
  }

  void _submitAnswer() {
    if (_selectedAnswers.isEmpty) return;

    final appState = context.read<AppState>();
    appState.answerQuestion(_selectedAnswers);
    
    setState(() => _showingFeedback = true);
  }

  void _nextQuestion() {
    final appState = context.read<AppState>();
    final quiz = appState.currentQuiz;
    
    if (appState.currentQuestionIndex < quiz!.questions.length - 1) {
      appState.nextQuestion();
      setState(() {
        _selectedAnswers = [];
        _showingFeedback = false;
      });
    } else {
      // Quiz completed
      _completeQuiz();
    }
  }

  Future<void> _completeQuiz() async {
    final appState = context.read<AppState>();
    await appState.submitQuiz();
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const QuizResultScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Confirm exit
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Exit Quiz?'),
                content: const Text(
                  'Your progress will be lost. Are you sure you want to exit?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Close quiz
                    },
                    child: const Text('Exit'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, _) {
          final quiz = appState.currentQuiz;
          final question = appState.currentQuestion;
          final session = appState.currentSession;
          
          if (quiz == null || question == null || session == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final progress = (appState.currentQuestionIndex + 1) / quiz.questions.length;
          final isCorrect = appState.isAnswerCorrect(question.id);

          return Column(
            children: [
              // Progress Bar
              LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppTheme.surfaceColor,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Question Number
                      Text(
                        'Question ${appState.currentQuestionIndex + 1} of ${quiz.questions.length}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppTheme.primaryColor,
                            ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Question Text
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            question.questionText,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                      
                      if (question.type == QuestionType.multipleSelect) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Select all that apply',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Answer Options
                      ...List.generate(question.options.length, (index) {
                        return _AnswerOption(
                          option: question.options[index],
                          index: index,
                          isSelected: _selectedAnswers.contains(index),
                          showingFeedback: _showingFeedback,
                          isCorrect: question.correctAnswerIndices.contains(index),
                          onTap: () => _handleAnswerSelection(index),
                        );
                      }),
                      
                      // Feedback Card
                      if (_showingFeedback) ...[
                        const SizedBox(height: 24),
                        Card(
                          color: isCorrect
                              ? AppTheme.successColor.withOpacity(0.1)
                              : AppTheme.errorColor.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isCorrect ? Icons.check_circle : Icons.cancel,
                                      color: isCorrect
                                          ? AppTheme.successColor
                                          : AppTheme.errorColor,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      isCorrect ? 'Correct!' : 'Incorrect',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: isCorrect
                                                ? AppTheme.successColor
                                                : AppTheme.errorColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  question.explanation,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Submit/Continue Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _showingFeedback
                        ? _nextQuestion
                        : (_selectedAnswers.isEmpty ? null : _submitAnswer),
                    child: Text(_showingFeedback ? 'Continue' : 'Submit Answer'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  final String option;
  final int index;
  final bool isSelected;
  final bool showingFeedback;
  final bool isCorrect;
  final VoidCallback onTap;

  const _AnswerOption({
    required this.option,
    required this.index,
    required this.isSelected,
    required this.showingFeedback,
    required this.isCorrect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    Color? borderColor;
    Color? textColor;

    if (showingFeedback) {
      if (isCorrect) {
        backgroundColor = AppTheme.successColor.withOpacity(0.1);
        borderColor = AppTheme.successColor;
        textColor = AppTheme.successColor;
      } else if (isSelected && !isCorrect) {
        backgroundColor = AppTheme.errorColor.withOpacity(0.1);
        borderColor = AppTheme.errorColor;
        textColor = AppTheme.errorColor;
      }
    } else if (isSelected) {
      backgroundColor = AppTheme.primaryColor.withOpacity(0.1);
      borderColor = AppTheme.primaryColor;
      textColor = AppTheme.primaryColor;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: backgroundColor ?? AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: showingFeedback ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: borderColor ?? AppTheme.borderColor,
                width: isSelected || showingFeedback ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Index Circle
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: borderColor?.withOpacity(0.2) ?? AppTheme.surfaceColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor ?? AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Option Text
                Expanded(
                  child: Text(
                    option,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: textColor,
                          fontWeight: isSelected ? FontWeight.w600 : null,
                        ),
                  ),
                ),
                
                // Check/X Icon when showing feedback
                if (showingFeedback && isCorrect)
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.successColor,
                  )
                else if (showingFeedback && isSelected && !isCorrect)
                  const Icon(
                    Icons.cancel,
                    color: AppTheme.errorColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
