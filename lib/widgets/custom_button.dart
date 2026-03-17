import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? textColor;
  final bool isOutlined;
  final bool fullWidth;
  final double? height;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
    this.textColor,
    this.isOutlined = false,
    this.fullWidth = true,
    this.height = 52,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? AppConstants.primaryColor;
    final fgColor = textColor ?? Colors.white;

    if (isOutlined) {
      return SizedBox(
        width: fullWidth ? double.infinity : null,
        height: height,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: icon != null ? Icon(icon, color: bgColor) : const SizedBox.shrink(),
          label: Text(
            label,
            style: TextStyle(
              color: bgColor,
              fontWeight: FontWeight.w600,
              fontSize: AppConstants.fontBody,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: bgColor, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, color: fgColor, size: 18) : const SizedBox.shrink(),
        label: Text(
          label,
          style: TextStyle(
            color: fgColor,
            fontWeight: FontWeight.w600,
            fontSize: AppConstants.fontBody,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
        ),
      ),
    );
  }
}
