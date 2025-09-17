import 'package:flutter/material.dart';
import '../models/schedule_model.dart'; // Import the schedule model
import 'stat_card.dart';

class DailyStatsRow extends StatelessWidget {
  final List<ScheduledEvent> schedule; // Accept a list of events
  const DailyStatsRow({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    // --- DYNAMIC DATA CALCULATION ---
    final totalTasks = schedule.length;
    final tasksDone = schedule.where((event) => event.isCompleted).length;

    return Row(
      children: [
        const StatCard(
          icon: Icons.local_fire_department_rounded,
          iconColor: Colors.orangeAccent,
          value: '1', // We'll make this dynamic later
          label: 'Day Streak',
        ),
        const SizedBox(width: 12),
        StatCard(
          icon: Icons.check_circle_rounded,
          iconColor: Colors.greenAccent,
          value: '$tasksDone/$totalTasks', // Use the dynamic task count
          label: 'Tasks Done',
        ),
        const SizedBox(width: 12),
        const StatCard(
          icon: Icons.hourglass_bottom_rounded,
          iconColor: Colors.cyanAccent,
          value: '0h', // We'll make this dynamic later
          label: 'Focus Hours',
        ),
      ],
    );
  }
}