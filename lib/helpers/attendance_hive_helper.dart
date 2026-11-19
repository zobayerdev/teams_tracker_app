import 'dart:developer';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class AttendanceStateModel {
  final bool isCheckedIn;
  final bool isCheckedOut;
  final String inTime;
  final String outTime;
  final String workingHours;

  const AttendanceStateModel({
    required this.isCheckedIn,
    required this.isCheckedOut,
    required this.inTime,
    required this.outTime,
    required this.workingHours,
  });

  factory AttendanceStateModel.initial() => const AttendanceStateModel(
        isCheckedIn: false,
        isCheckedOut: false,
        inTime: "--:--",
        outTime: "--:--",
        workingHours: "0h 0m",
      );
}

final class AttendanceHiveHelper {
  static const String boxName = 'attendance_box';
  static const String keyDate = 'attendance_date';
  static const String keyIsCheckedIn = 'is_checked_in';
  static const String keyIsCheckedOut = 'is_checked_out';
  static const String keyInTime = 'in_time';
  static const String keyOutTime = 'out_time';
  static const String keyWorkingHours = 'working_hours';
  static const String keyInTimeRaw = 'in_time_raw';

  /// Ensure box is open and check date-wise reset.
  /// If today is a new date, clear the box.
  static Future<AttendanceStateModel> getAttendanceState() async {
    try {
      final Box box = Hive.isBoxOpen(boxName)
          ? Hive.box(boxName)
          : await Hive.openBox(boxName);

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final savedDate = box.get(keyDate);

      // On a different date, wipe the box
      if (savedDate == null || savedDate != today) {
        log('AttendanceHiveHelper: Date changed ($savedDate -> $today). Clearing Hive box.');
        await box.clear();
        await box.put(keyDate, today);
        return AttendanceStateModel.initial();
      }

      return AttendanceStateModel(
        isCheckedIn: box.get(keyIsCheckedIn, defaultValue: false) as bool,
        isCheckedOut: box.get(keyIsCheckedOut, defaultValue: false) as bool,
        inTime: box.get(keyInTime, defaultValue: "--:--") as String,
        outTime: box.get(keyOutTime, defaultValue: "--:--") as String,
        workingHours: box.get(keyWorkingHours, defaultValue: "0h 0m") as String,
      );
    } catch (e) {
      log('Error reading attendance state from Hive: $e');
      return AttendanceStateModel.initial();
    }
  }

  /// Save check-in details for today
  static Future<void> saveCheckIn({
    required String displayTime,
    required DateTime checkInDateTime,
  }) async {
    try {
      final Box box = Hive.isBoxOpen(boxName)
          ? Hive.box(boxName)
          : await Hive.openBox(boxName);

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await box.put(keyDate, today);
      await box.put(keyIsCheckedIn, true);
      await box.put(keyIsCheckedOut, false);
      await box.put(keyInTime, displayTime);
      await box.put(keyInTimeRaw, checkInDateTime.toIso8601String());
    } catch (e) {
      log('Error saving check-in to Hive: $e');
    }
  }

  /// Save check-out details for today
  static Future<void> saveCheckOut({
    required String displayTime,
    required String workingHours,
  }) async {
    try {
      final Box box = Hive.isBoxOpen(boxName)
          ? Hive.box(boxName)
          : await Hive.openBox(boxName);

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await box.put(keyDate, today);
      await box.put(keyIsCheckedIn, true);
      await box.put(keyIsCheckedOut, true);
      await box.put(keyOutTime, displayTime);
      await box.put(keyWorkingHours, workingHours);
    } catch (e) {
      log('Error saving check-out to Hive: $e');
    }
  }

  /// Retrieve raw DateTime of check-in to calculate working hours
  static DateTime? getRawCheckInTime() {
    try {
      if (!Hive.isBoxOpen(boxName)) return null;
      final raw = Hive.box(boxName).get(keyInTimeRaw);
      if (raw is String) {
        return DateTime.tryParse(raw);
      }
    } catch (e) {
      log('Error getting raw check-in time: $e');
    }
    return null;
  }
}
