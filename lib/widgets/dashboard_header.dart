import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data - we will make this dynamic later
    final double studyProgress = 0.6; // 60%
    final double tasksProgress = 0.8; // 80%

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Good morning, Helios.",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            Text(
              "Let's make it count.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildProgressRing(studyProgress, Colors.cyan, Icons.school_rounded),
            const SizedBox(width: 16),
            _buildProgressRing(tasksProgress, Colors.purpleAccent, Icons.check_circle_outline_rounded),
          ],
        )
      ],
    );
  }

  Widget _buildProgressRing(double progress, Color color, IconData icon) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Center(
            child: Icon(
              icon,
              color: color.withOpacity(0.8),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}