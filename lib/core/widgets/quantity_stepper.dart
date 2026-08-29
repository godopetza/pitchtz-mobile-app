import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The − [value] + control used for extras quantities and split player counts.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    this.canDecrement = true,
  });

  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool canDecrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _btn(
          '−',
          onTap: canDecrement ? onDecrement : null,
          filled: false,
          dim: !canDecrement,
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 20,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ),
        const SizedBox(width: 12),
        _btn('+', onTap: onIncrement, filled: true),
      ],
    );
  }

  Widget _btn(String label,
      {VoidCallback? onTap, required bool filled, bool dim = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: dim ? 0.35 : 1,
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(9),
            border: filled ? null : Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: filled ? AppColors.cream : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
