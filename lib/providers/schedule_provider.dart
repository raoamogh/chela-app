import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/schedule_model.dart';
import '../api/api_service.dart';

class ScheduleNotifier extends StateNotifier<AsyncValue<List<ScheduledEvent>>> {
  ScheduleNotifier() : super(const AsyncValue.loading()) {
    fetchSchedule();
  }

  Future<void> fetchSchedule() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ApiService.getSchedule());
  }

  Future<void> addTask(CreateScheduledEvent event) async {
    await ApiService.addTask(event);
    await fetchSchedule();
  }

  // --- THE NEW, SIMPLER LOGIC ---
  Future<void> completeTask(String eventId) async {
    // First, tell the backend to update the data
    await ApiService.completeTask(eventId);
    // THEN, force a refresh of the entire list from the server
    await fetchSchedule();
  }
  
  Future<void> undoTask(String eventId) async {
    await ApiService.undoCompleteTask(eventId);
    await fetchSchedule();
  }
}

final scheduleProvider = StateNotifierProvider<ScheduleNotifier, AsyncValue<List<ScheduledEvent>>>((ref) {
  return ScheduleNotifier();
});