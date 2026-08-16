import 'package:flutter/material.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class TimerWidget extends StatelessWidget {
  final int timeCount;
  final String timeUnit;
  const TimerWidget(
      {super.key, required this.timeUnit, required this.timeCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 55,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3FE281), Color(0xFF209E51)], // Vibrant emerald gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16), // Large rounded corners
            boxShadow: [
              // Soft glow
              BoxShadow(
                color: const Color(0xFF2EAA60).withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
              // Inner glossy highlight
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: -2,
                offset: const Offset(0, -2),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            timeCount > 9 ? timeCount.toString() : '0${timeCount.toString()}',
            style: robotoBold.copyWith(color: Colors.white, fontSize: 24, letterSpacing: 1),
          ),
        ),
        const SizedBox(height: 8),
        Text(timeUnit,
            style: robotoMedium.copyWith(
                fontSize: 14,
                color: const Color(0xFF1B6E3A),
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
