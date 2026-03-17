import 'package:flutter/material.dart';
import '../utils/constants.dart';

enum PopupType { correct, incorrect, info }

Future<void> showPopupMessage(
  BuildContext context, {
  required PopupType type,
  required String title,
  required String message,
  String? correctTerm,
  VoidCallback? onDismiss,
  bool autoDismiss = false,
  Duration autoDismissDuration = const Duration(seconds: 2),
}) async {
  if (!context.mounted) return;

  final isCorrect = type == PopupType.correct;
  final isIncorrect = type == PopupType.incorrect;

  Color headerColor = isCorrect
      ? AppConstants.successColor
      : isIncorrect
          ? AppConstants.errorColor
          : AppConstants.primaryColor;

  IconData headerIcon = isCorrect
      ? Icons.check_circle_rounded
      : isIncorrect
          ? Icons.cancel_rounded
          : Icons.info_rounded;

  if (autoDismiss) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _PopupDialog(
        type: type,
        title: title,
        message: message,
        correctTerm: correctTerm,
        headerColor: headerColor,
        headerIcon: headerIcon,
      ),
    );
    await Future.delayed(autoDismissDuration);
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    onDismiss?.call();
  } else {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _PopupDialog(
        type: type,
        title: title,
        message: message,
        correctTerm: correctTerm,
        headerColor: headerColor,
        headerIcon: headerIcon,
        onDismiss: onDismiss,
      ),
    );
  }
}

class _PopupDialog extends StatelessWidget {
  final PopupType type;
  final String title;
  final String message;
  final String? correctTerm;
  final Color headerColor;
  final IconData headerIcon;
  final VoidCallback? onDismiss;

  const _PopupDialog({
    required this.type,
    required this.title,
    required this.message,
    this.correctTerm,
    required this.headerColor,
    required this.headerIcon,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingLarge),
            color: headerColor,
            child: Column(
              children: [
                Icon(headerIcon, color: Colors.white, size: 52),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppConstants.fontLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: AppConstants.fontBody,
                    color: AppConstants.textSecondary,
                    height: 1.5,
                  ),
                ),
                if (correctTerm != null) ...[
                  const SizedBox(height: AppConstants.paddingMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium,
                      vertical: AppConstants.paddingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.successColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                      border: Border.all(color: AppConstants.successColor.withAlpha(80)),
                    ),
                    child: Text(
                      correctTerm!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: AppConstants.fontTitle,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.successColor,
                      ),
                    ),
                  ),
                ],
                if (onDismiss != null) ...[
                  const SizedBox(height: AppConstants.paddingLarge),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onDismiss?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: headerColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
