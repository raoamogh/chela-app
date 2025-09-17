import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/schedule_model.dart';
import '../providers/schedule_provider.dart';

// The modal needs to be a ConsumerStatefulWidget to use `ref` and have a controller
class AddTaskModal extends ConsumerStatefulWidget {
  const AddTaskModal({super.key});

  @override
  ConsumerState<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends ConsumerState<AddTaskModal> {
  final _subjectController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  void _submitData() {
    final enteredSubject = _subjectController.text.trim();
    if (enteredSubject.isEmpty) {
      return; // Don't submit if the field is empty
    }

    // Create a new event object with dummy data for now
    final newEvent = CreateScheduledEvent(
      subject: enteredSubject,
      startTime: "7:00 PM",
      endTime: "8:00 PM",
      color: "#FF5722", // Deep Orange
      location: "Home",
    );

    // Use the `ref` to call the addTask method on our provider
    ref.read(scheduleProvider.notifier).addTask(newEvent);

    // Close the modal
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // This padding ensures the modal moves up when the keyboard appears
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Add New Task", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(labelText: 'Subject'),
            autofocus: true, // Automatically focus the text field
            onSubmitted: (_) => _submitData(), // Submit when the user presses "done"
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitData,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text("Add Task"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}