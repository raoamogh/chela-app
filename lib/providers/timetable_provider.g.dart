// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$timetableNotifierHash() => r'8f6375c9ff505f3231bca8f23b1774e73de40b12';

/// See also [TimetableNotifier].
@ProviderFor(TimetableNotifier)
final timetableNotifierProvider =
    AutoDisposeStreamNotifierProvider<
      TimetableNotifier,
      List<TimetableEntry>
    >.internal(
      TimetableNotifier.new,
      name: r'timetableNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$timetableNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TimetableNotifier = AutoDisposeStreamNotifier<List<TimetableEntry>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
