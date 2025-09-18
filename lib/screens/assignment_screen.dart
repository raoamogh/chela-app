// lib/screens/assignment_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../providers/assignment_provider.dart';
import '../models/assignment_model.dart';

class AssignmentScreen extends ConsumerWidget {
  const AssignmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsyncValue = ref.watch(assignmentNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Assignments'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Call the dialog function for adding a new assignment
              _showAddEditAssignmentDialog(context, ref);
            },
          ),
        ],
      ),
      body: assignmentsAsyncValue.when(
        data: (assignments) {
          if (assignments.isEmpty) {
            return const Center(
              child: Text(
                "No assignments yet. Tap '+' to add one!",
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            );
          }

          // Separate completed from pending for better display
          final pendingAssignments = assignments.where((a) => !a.isCompleted).toList();
          final completedAssignments = assignments.where((a) => a.isCompleted).toList();

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (pendingAssignments.isNotEmpty) ...[
                Text('Pending Assignments', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
                const Divider(color: Colors.white30),
                ...pendingAssignments.map((assignment) =>
                    _buildAssignmentCard(context, ref, assignment, true)).toList(),
                const SizedBox(height: 24),
              ],
              if (completedAssignments.isNotEmpty) ...[
                Text('Completed Assignments', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey)),
                const Divider(color: Colors.white30),
                ...completedAssignments.map((assignment) =>
                    _buildAssignmentCard(context, ref, assignment, false)).toList(),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildAssignmentCard(BuildContext context, WidgetRef ref, Assignment assignment, bool showCheckbox) {
    final DateFormat formatter = DateFormat('MMM dd, yyyy HH:mm');
    final bool isOverdue = !assignment.isCompleted && assignment.dueDate.isBefore(DateTime.now());

    Color cardColor = Theme.of(context).cardColor;
    if (isOverdue) {
      cardColor = Colors.red.withOpacity(0.1); // Light red for overdue
    } else {
      // Use priority to influence color slightly, but ensure it's subtle
      switch(assignment.priority) {
        case 3: // High
          cardColor = Colors.orange.withOpacity(0.1);
          break;
        case 2: // Medium
          cardColor = Colors.blue.withOpacity(0.1);
          break;
        case 1: // Low
        default:
          cardColor = Theme.of(context).cardColor; // Default card color
          break;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      color: cardColor,
      child: ListTile(
        leading: showCheckbox
            ? Checkbox(
                value: assignment.isCompleted,
                onChanged: (bool? newValue) {
                  if (newValue != null) {
                    ref.read(assignmentNotifierProvider.notifier).updateAssignment(
                      assignment.copyWith(isCompleted: newValue),
                    );
                  }
                },
                activeColor: Theme.of(context).colorScheme.primary,
              )
            : const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
        title: Text(
          assignment.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: assignment.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
            color: assignment.isCompleted ? Colors.white54 : Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${assignment.subjectName} - Due: ${formatter.format(assignment.dueDate)}',
              style: TextStyle(
                color: isOverdue ? Colors.redAccent : Colors.white70,
                fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Text('Priority: ${assignment.priority}', style: const TextStyle(color: Colors.white60)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
          onPressed: () {
            // Show confirmation dialog before deleting
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete Assignment?'),
                content: Text('Are you sure you want to delete "${assignment.title}"? This cannot be undone.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(assignmentNotifierProvider.notifier).deleteAssignment(assignment.id);
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Delete'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            );
          },
        ),
        onTap: () {
          // Call the dialog function for editing an existing assignment
          _showAddEditAssignmentDialog(context, ref, assignment: assignment);
        },
      ),
    );
  }

  // --- UPDATED: _showAddEditAssignmentDialog now includes reminder options ---
  void _showAddEditAssignmentDialog(BuildContext context, WidgetRef ref, {Assignment? assignment}) {
    final isEditing = assignment != null;
    final subjectController = TextEditingController(text: assignment?.subjectName);
    final titleController = TextEditingController(text: assignment?.title);
    
    // Initial values for the dialog's state, based on existing assignment or defaults
    DateTime selectedDueDate = assignment?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    int selectedPriority = assignment?.priority ?? 3; // Default to medium (3)
    bool isCompleted = assignment?.isCompleted ?? false; // Retain completion status if editing

    // Reminder options state
    List<int> selectedReminderHours = List.from(assignment?.reminderHoursBefore ?? [24]); // Default 24h before

    // List of available reminder options to display in checkboxes
    final List<Map<String, dynamic>> availableReminderOptions = const [
      {'hours': 1, 'label': '1 Hour Before'},
      {'hours': 3, 'label': '3 Hours Before'},
      {'hours': 12, 'label': '12 Hours Before'},
      {'hours': 24, 'label': '1 Day Before'},
      {'hours': 24 * 2, 'label': '2 Days Before'}, // 2 days
      {'hours': 24 * 7, 'label': '1 Week Before'}, // 1 week
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Use StatefulBuilder to manage internal state of the dialog
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Assignment' : 'Add Assignment'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: subjectController,
                      decoration: const InputDecoration(labelText: 'Subject Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Subject cannot be empty';
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Assignment Title'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Title cannot be empty';
                        return null;
                      },
                    ),
                    ListTile(
                      title: const Text('Due Date & Time'),
                      subtitle: Text(DateFormat('MMM dd, yyyy HH:mm').format(selectedDueDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        // Date picker
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDueDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)), // Allow past dates for editing
                          lastDate: DateTime.now().add(const Duration(days: 365 * 5)), // Up to 5 years in future
                        );
                        if (pickedDate != null) {
                          // Time picker
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(selectedDueDate),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              selectedDueDate = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            });
                          }
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('Priority'),
                      trailing: DropdownButton<int>(
                        value: selectedPriority,
                        onChanged: (int? newValue) {
                          if (newValue != null) {
                            setState(() { selectedPriority = newValue; });
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('1 (Low)')),
                          DropdownMenuItem(value: 2, child: Text('2 (Medium)')),
                          DropdownMenuItem(value: 3, child: Text('3 (High)')),
                        ],
                      ),
                    ),
                    // Only show completed checkbox if editing
                    if (isEditing)
                      Row(
                        children: [
                          const Text('Completed:'),
                          Checkbox(
                            value: isCompleted,
                            onChanged: (newValue) {
                              setState(() {
                                isCompleted = newValue!;
                              });
                            },
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: 20),
                    Text('Reminder Options', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    // --- Reminder Options UI ---
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: availableReminderOptions.map((option) {
                        final int hours = option['hours'];
                        final String label = option['label'];
                        return CheckboxListTile(
                          title: Text(label),
                          value: selectedReminderHours.contains(hours),
                          onChanged: (bool? newValue) {
                            setState(() {
                              if (newValue == true) {
                                selectedReminderHours.add(hours);
                              } else {
                                selectedReminderHours.remove(hours);
                              }
                              selectedReminderHours.sort(); // Keep sorted
                            });
                          },
                        );
                      }).toList(),
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
                    if (subjectController.text.trim().isEmpty || titleController.text.trim().isEmpty) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Subject and Title cannot be empty')),
                        );
                      }
                      return;
                    }

                    final assignmentToSave = Assignment(
                      id: isEditing ? assignment!.id : '', // Use existing ID for editing
                      subjectName: subjectController.text.trim(),
                      title: titleController.text.trim(),
                      dueDate: selectedDueDate,
                      isCompleted: isEditing ? isCompleted : false, // Use dialog's isCompleted for editing
                      priority: selectedPriority,
                      reminderHoursBefore: selectedReminderHours, // Save the selected reminder hours
                    );

                    if (isEditing) {
                      await ref.read(assignmentNotifierProvider.notifier).updateAssignment(assignmentToSave);
                    } else {
                      await ref.read(assignmentNotifierProvider.notifier).addAssignment(assignmentToSave);
                    }
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: Text(isEditing ? 'Save Changes' : 'Add Assignment'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}