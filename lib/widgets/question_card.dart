import 'package:flutter/material.dart';
import '../utils/constants.dart';

class QuestionCard extends StatelessWidget {
  final int questionNumber;
  final int totalQuestions;
  final String meaning;
  final TextEditingController answerController;
  final VoidCallback onSubmit;
  final bool isLoading;
  final VoidCallback onSkip;
  final String? topicName;
  final String clue;

  const QuestionCard({
    super.key,
    required this.questionNumber,
    required this.totalQuestions,
    required this.meaning,
    required this.answerController,
    required this.onSubmit,
    required this.onSkip,
    required this.clue,
    this.topicName,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question $questionNumber of $totalQuestions',
                  style: const TextStyle(
                    fontSize: AppConstants.fontSmall,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  ),
                  child: Text(
                    '$questionNumber/$totalQuestions',
                    style: const TextStyle(
                      fontSize: AppConstants.fontSmall,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: questionNumber / totalQuestions,
                backgroundColor: AppConstants.dividerColor,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppConstants.primaryColor,
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: AppConstants.paddingLarge),

            // Meaning section label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MEANING',
                  style: TextStyle(
                    fontSize: AppConstants.fontSmall,
                    fontWeight: FontWeight.w700,
                    color: AppConstants.accentColor,
                    letterSpacing: 1.5,
                  ),
                ),
                if (topicName != null && topicName!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppConstants.accentColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppConstants.accentColor.withAlpha(50)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.category_outlined, size: 14, color: AppConstants.accentColor),
                        const SizedBox(width: 4),
                        Text(
                          topicName!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),

            // Meaning text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: AppConstants.backgroundColor,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                border: Border.all(color: AppConstants.dividerColor),
              ),
              child: Text(
                meaning,
                style: const TextStyle(
                  fontSize: AppConstants.fontTitle,
                  color: AppConstants.textPrimary,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingLarge),

            // Answer label
            const Text(
              'YOUR ANSWER',
              style: TextStyle(
                fontSize: AppConstants.fontSmall,
                fontWeight: FontWeight.w700,
                color: AppConstants.accentColor,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),

            // Clue display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withAlpha(15),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                border: Border.all(color: AppConstants.primaryColor.withAlpha(50)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, size: 20, color: AppConstants.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Clue: $clue',
                      style: const TextStyle(
                        fontSize: AppConstants.fontBody,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.primaryColor,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Text Input
            TextField(
              controller: answerController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Type the correct term...',
                hintStyle: const TextStyle(color: AppConstants.textSecondary),
                filled: true,
                fillColor: AppConstants.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  borderSide: const BorderSide(color: AppConstants.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  borderSide: const BorderSide(color: AppConstants.dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  borderSide: const BorderSide(
                    color: AppConstants.primaryColor,
                    width: 1.5,
                  ),
                ),
                suffixIcon: answerController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppConstants.textSecondary),
                        onPressed: () => answerController.clear(),
                      )
                    : null,
              ),
              onSubmitted: (_) => onSubmit(),
            ),
            const SizedBox(height: AppConstants.paddingLarge),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Submit Answer',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: AppConstants.fontBody,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Skip button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: isLoading ? null : onSkip,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppConstants.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Skip Question',
                      style: TextStyle(
                        color: AppConstants.primaryColor,
                        fontSize: AppConstants.fontBody,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.skip_next_rounded, color: AppConstants.primaryColor, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

