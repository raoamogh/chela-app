import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/schedule_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/daily_stats_row.dart';
import '../widgets/add_task_modal.dart';
import '../models/schedule_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  int _getHourIn24Format(String time) {
    final parts = time.split(' ');
    final timeParts = parts[0].split(':');
    var hour = int.parse(timeParts[0]);
    final period = parts[1].toUpperCase();
    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;
    return hour;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsyncValue = ref.watch(scheduleProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(scheduleProvider.notifier).fetchSchedule(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DashboardHeader(),
                  const SizedBox(height: 24),
                  scheduleAsyncValue.when(
                    data: (schedule) => DailyStatsRow(schedule: schedule),
                    error: (e, s) => const SizedBox(height: 105),
                    loading: () => const SizedBox(height: 105),
                  ),
                  const SizedBox(height: 24),
                  const Text("TODAY'S SCHEDULE", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  scheduleAsyncValue.when(
                    data: (schedule) => _buildScheduleList(context, schedule, ref),
                    error: (err, stack) => Center(child: Padding(padding: const EdgeInsets.all(40.0), child: Text("Error loading schedule.", style: TextStyle(color: Colors.redAccent)))),
                    loading: () => const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator())),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            builder: (ctx) => const AddTaskModal(),
          ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Color(0xFF121212)),
      ),
    );
  }
  
  Widget _buildScheduleList(BuildContext context, List<ScheduledEvent> schedule, WidgetRef ref) {
    if (schedule.isEmpty) return const Padding(padding: EdgeInsets.symmetric(vertical: 40.0), child: Center(child: Text("Schedule is empty. Add a task!")));
    
    final groupedSchedule = groupBy(schedule, (event) {
      final hour = _getHourIn24Format(event.startTime);
      if (hour < 12) return 'MORNING';
      if (hour < 17) return 'AFTERNOON';
      return 'EVENING';
    });
    final groupKeys = groupedSchedule.keys.toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupKeys.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final groupName = groupKeys[index];
        final eventsInGroup = groupedSchedule[groupName]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(groupName, style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            ...eventsInGroup.map((event) => Dismissible(
                  key: Key(event.id),
                  direction: event.isCompleted ? DismissDirection.none : DismissDirection.startToEnd,
                  // --- THE SIMPLIFIED LOGIC ---
                  // onDismissed fires after the animation. This is the safe place to update state.
                  onDismissed: (direction) {
                    ref.read(scheduleProvider.notifier).completeTask(event.id);
                  },
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(color: Colors.green.shade700, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                  ),
                  child: _EventCard(event: event),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0)
            ),
          ],
        );
      },
    );
  }
}

// _EventCard widget remains the same
class _EventCard extends StatelessWidget {
  final ScheduledEvent event;
  const _EventCard({required this.event});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10, width: 1)),
      child: Row(
        children: [
          Container(width: 4, height: 60, decoration: BoxDecoration(color: event.isCompleted ? Colors.grey : event.color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.subject, style: TextStyle(color: event.isCompleted ? Colors.grey : Colors.white, fontSize: 18, fontWeight: FontWeight.bold, decoration: event.isCompleted ? TextDecoration.lineThrough : TextDecoration.none)),
                const SizedBox(height: 4),
                Text("${event.startTime} - ${event.endTime}", style: TextStyle(color: event.isCompleted ? Colors.grey.withOpacity(0.7) : Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text(event.location, style: TextStyle(color: event.isCompleted ? Colors.grey.withOpacity(0.5) : Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}