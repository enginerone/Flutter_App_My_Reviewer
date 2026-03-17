import 'package:flutter/material.dart';
import '../../models/question_model.dart';
import '../../models/result_model.dart';
import '../../models/subject_model.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import 'question_screen.dart';

class ResultScreen extends StatelessWidget {
  final UserModel user;
  final SubjectModel subject;
  final List<QuestionModel> questions;
  final ResultModel result;

  const ResultScreen({
    super.key,
    required this.user,
    required this.subject,
    required this.questions,
    required this.result,
  });

  Color get _scoreColor {
    if (result.score >= 80) return AppConstants.successColor;
    if (result.score >= 50) return const Color(0xFFF57C00);
    return AppConstants.errorColor;
  }

  String get _scoreLabel {
    if (result.score >= 80) return 'Excellent! 🎉';
    if (result.score >= 50) return 'Good Job! 👍';
    return 'Keep Practicing! 💪';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            children: [
              const SizedBox(height: AppConstants.paddingLarge),

              // Score circle
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _scoreColor.withAlpha(20),
                  border: Border.all(color: _scoreColor, width: 5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${result.score}%',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: _scoreColor,
                      ),
                    ),
                    Text(
                      'Score',
                      style: TextStyle(
                        fontSize: AppConstants.fontSmall,
                        color: _scoreColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingLarge),

              // Praise label
              Text(
                _scoreLabel,
                style: const TextStyle(
                  fontSize: AppConstants.fontLarge,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subject.subjectName,
                style: const TextStyle(
                  fontSize: AppConstants.fontBody,
                  color: AppConstants.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.paddingLarge),

              // Stats card
              Card(
                elevation: AppConstants.cardElevation,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Column(
                    children: [
                      _statRow('Total Questions', '${result.totalQuestions}',
                          Icons.help_outline_rounded, AppConstants.primaryColor),
                      const Divider(),
                      _statRow('Correct Answers', '${result.correctAnswers}',
                          Icons.check_circle_outline_rounded, AppConstants.successColor),
                      const Divider(),
                      _statRow(
                        'Incorrect Answers',
                        '${result.totalQuestions - result.correctAnswers}',
                        Icons.cancel_outlined,
                        AppConstants.errorColor,
                      ),
                      const Divider(),
                      _statRow(
                        'Date Taken',
                        result.dateTaken,
                        Icons.calendar_today_outlined,
                        AppConstants.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingLarge),

              // Buttons
              CustomButton(
                label: 'Repeat Quiz',
                icon: Icons.replay_rounded,
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => QuestionScreen(
                        user: user,
                        subject: subject,
                        questions: questions,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              CustomButton(
                label: 'Back to Subjects',
                icon: Icons.arrow_back_rounded,
                isOutlined: true,
                onPressed: () {
                  // Pop back to SubjectListScreen
                  Navigator.of(context).popUntil(
                    (route) => route.settings.name == '/' || route.isFirst,
                  );
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: AppConstants.paddingLarge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: AppConstants.fontBody,
                color: AppConstants.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: AppConstants.fontBody,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
