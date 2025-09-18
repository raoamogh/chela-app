import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timetable_provider.dart';
import '../models/timetable_entry_model.dart';

class TimetableScreen extends ConsumerWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timetableAsyncValue = ref.watch(timetableNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('College Timetable'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to Add/Edit Timetable Entry Screen
              _showAddEntryDialog(context, ref);
            },
          ),
        ],
      ),
      body: timetableAsyncValue.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(
              child: Text(
                "No timetable entries yet. Tap '+' to add one!",
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            );
          }
          // Group entries by day for better display
          final Map<DayOfWeek, List<TimetableEntry>> groupedEntries = {};
          for (var day in DayOfWeek.values) {
            groupedEntries[day] =
                entries.where((e) => e.day == day).toList();
            // Sort by start time within each day
            groupedEntries[day]!.sort((a, b) => a.startTime.compareTo(b.startTime));
          }

          return ListView.builder(
            itemCount: DayOfWeek.values.length,
            itemBuilder: (context, index) {
              final day = DayOfWeek.values[index];
              final dayEntries = groupedEntries[day]!;

              if (dayEntries.isEmpty) {
                return const SizedBox.shrink(); // Hide if no entries for the day
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dayToString(day),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Divider(color: Colors.white30),
                    ...dayEntries.map((entry) => _buildTimetableEntryCard(context, ref, entry)).toList(),
                    const SizedBox(height: 16), // Space between days
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildTimetableEntryCard(BuildContext context, WidgetRef ref, TimetableEntry entry) {
    final startTime = TimeOfDay.fromDateTime(entry.startTime);
    final endTime = TimeOfDay.fromDateTime(entry.endTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      color: Theme.of(context).cardColor,
      child: ListTile(
        leading: Icon(Icons.class_rounded, color: Theme.of(context).colorScheme.secondary),
        title: Text(
          entry.subjectName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${startTime.format(context)} - ${endTime.format(context)}'),
            if (entry.location != null && entry.location!.isNotEmpty)
              Text('Location: ${entry.location}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
          onPressed: () => ref.read(timetableNotifierProvider.notifier).deleteEntry(entry.id),
        ),
        onTap: () {
          // TODO: Implement edit functionality
          _showAddEntryDialog(context, ref, entry: entry); // Use same dialog for edit
        },
      ),
    );
  }

  String _dayToString(DayOfWeek day) {
    return day.toString().split('.').last.toUpperCase();
  }

  // --- NEW: Add/Edit Entry Dialog ---
  void _showAddEntryDialog(BuildContext context, WidgetRef ref, {TimetableEntry? entry}) {
    final isEditing = entry != null;
    final subjectController = TextEditingController(text: entry?.subjectName);
    final locationController = TextEditingController(text: entry?.location);
    DayOfWeek selectedDay = entry?.day ?? DayOfWeek.monday;
    TimeOfDay selectedStartTime = entry != null ? TimeOfDay.fromDateTime(entry.startTime) : TimeOfDay.now();
    TimeOfDay selectedEndTime = entry != null ? TimeOfDay.fromDateTime(entry.endTime) : TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Use StatefulBuilder to update dialog UI
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Timetable Entry' : 'Add Timetable Entry'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: subjectController,
                      decoration: const InputDecoration(labelText: 'Subject Name'),
                    ),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(labelText: 'Location (Optional)'),
                    ),
                    ListTile(
                      title: const Text('Day'),
                      trailing: DropdownButton<DayOfWeek>(
                        value: selectedDay,
                        onChanged: (DayOfWeek? newValue) {
                          if (newValue != null) {
                            setState(() { selectedDay = newValue; });
                          }
                        },
                        items: DayOfWeek.values.map<DropdownMenuItem<DayOfWeek>>((DayOfWeek day) {
                          return DropdownMenuItem<DayOfWeek>(
                            value: day,
                            child: Text(_dayToString(day)),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      title: const Text('Start Time'),
                      trailing: TextButton(
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: selectedStartTime,
                          );
                          if (picked != null && picked != selectedStartTime) {
                            setState(() { selectedStartTime = picked; });
                          }
                        },
                        child: Text(selectedStartTime.format(context)),
                      ),
                    ),
                    ListTile(
                      title: const Text('End Time'),
                      trailing: TextButton(
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: selectedEndTime,
                          );
                          if (picked != null && picked != selectedEndTime) {
                            setState(() { selectedEndTime = picked; });
                          }
                        },
                        child: Text(selectedEndTime.format(context)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (subjectController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Subject Name cannot be empty')),
                      );
                      return;
                    }

                    // Combine selected date (arbitrary, as we only care about time) and time
                    final now = DateTime.now();
                    final entryStartTime = DateTime(now.year, now.month, now.day, selectedStartTime.hour, selectedStartTime.minute);
                    final entryEndTime = DateTime(now.year, now.month, now.day, selectedEndTime.hour, selectedEndTime.minute);

                    final newEntry = TimetableEntry(
                      id: isEditing ? entry!.id : '', // Use existing ID for update
                      subjectName: subjectController.text.trim(),
                      location: locationController.text.trim(),
                      day: selectedDay,
                      startTime: entryStartTime,
                      endTime: entryEndTime,
                    );

                    if (isEditing) {
                      await ref.read(timetableNotifierProvider.notifier).updateEntry(newEntry);
                    } else {
                      await ref.read(timetableNotifierProvider.notifier).addEntry(newEntry);
                    }
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: Text(isEditing ? 'Save Changes' : 'Add Entry'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}