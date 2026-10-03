import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WeeklyChart extends StatelessWidget {
  const WeeklyChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Chiều cao tương đối các cột theo biểu đồ Figma
    final days = [
      {'label': 'T2', 'ratio': 0.40, 'isHighlight': false},
      {'label': 'T3', 'ratio': 0.65, 'isHighlight': false},
      {'label': 'T4', 'ratio': 0.35, 'isHighlight': false},
      {'label': 'T5', 'ratio': 0.85, 'isHighlight': false},
      {'label': 'T6', 'ratio': 0.55, 'isHighlight': false},
      {'label': 'T7', 'ratio': 0.70, 'isHighlight': false},
      {'label': 'CN', 'ratio': 0.95, 'isHighlight': true},
    ];

    return SizedBox(
      height: 160,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: days.map((day) {
          final ratio = day['ratio'] as double;
          final isHighlight = day['isHighlight'] as bool;
          final label = day['label'] as String;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: ratio,
                    child: Container(
                      width: 28,
                      decoration: BoxDecoration(
                        color: isHighlight ? AppColors.secondaryTeal : AppColors.primary,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isHighlight ? AppColors.primary : AppColors.textSub,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
