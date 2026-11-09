import 'package:medi_reminder/services/storage_service.dart';
import 'package:medi_reminder/services/notification_service.dart';

class Medicine {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final String startDate;
  final String? endDate;

  final String reminderTime;
  final List<String> reminderTimes;
  final String notes;
  final bool isActive;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.reminderTime,
    List<String>? reminderTimes,
    this.notes = '',
    this.isActive = true,
  }) : reminderTimes =
            reminderTimes ?? (reminderTime.isEmpty ? const [] : [reminderTime]);

  factory Medicine.fromJson(Map<String, dynamic> j) {
    final savedTimes = (j['reminderTimes'] as List?)
            ?.map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList() ??
        <String>[];

    final oldTime = j['reminderTime'] as String? ?? '';

    return Medicine(
      id: j['id'] as String,
      name: j['name'] as String,
      dosage: j['dosage'] as String,
      frequency: j['frequency'] as String,
      startDate: j['startDate'] as String,
      endDate: j['endDate'] as String?,
      reminderTime: oldTime.isNotEmpty
          ? oldTime
          : (savedTimes.isNotEmpty ? savedTimes.first : ''),
      reminderTimes: savedTimes.isNotEmpty
          ? savedTimes
          : (oldTime.isNotEmpty ? [oldTime] : <String>[]),
      notes: (j['notes'] as String?) ?? '',
      isActive: (j['isActive'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'startDate': startDate,
        'endDate': endDate,
        'reminderTime': reminderTime,
        'reminderTimes': reminderTimes,
        'notes': notes,
        'isActive': isActive,
      };

  Medicine copyWith({
    String? name,
    String? dosage,
    String? frequency,
    String? startDate,
    String? endDate,
    String? reminderTime,
    List<String>? reminderTimes,
    String? notes,
    bool? isActive,
  }) {
    final updatedTimes = reminderTimes ?? this.reminderTimes;

    return Medicine(
      id: id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reminderTime: reminderTime ??
          (reminderTimes != null
              ? (updatedTimes.isNotEmpty ? updatedTimes.first : '')
              : this.reminderTime),
      reminderTimes: updatedTimes,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }
}

class HistoryEntry {
  final String id;
  final String medicineId;
  final String medicineName;
  final String dateTime;
  final String status;
  final String? scheduledDateTime;
  final String? occurrenceKey;

  const HistoryEntry({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.dateTime,
    required this.status,
    this.scheduledDateTime,
    this.occurrenceKey,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> j) {
    return HistoryEntry(
      id: j['id']?.toString() ?? '',
      medicineId: j['medicineId']?.toString() ?? '',
      medicineName: j['medicineName']?.toString() ?? '',
      dateTime: j['dateTime']?.toString() ?? '',
      status: j['status']?.toString() ?? '',
      scheduledDateTime: j['scheduledDateTime']?.toString(),
      occurrenceKey: j['occurrenceKey']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'medicineId': medicineId,
        'medicineName': medicineName,
        'dateTime': dateTime,
        'status': status,
        'scheduledDateTime': scheduledDateTime,
        'occurrenceKey': occurrenceKey,
      };
}

class MedicineService {
  MedicineService._();

  static final instance = MedicineService._();

  static const _medKey = 'medicines';
  static const _historyKey = 'medicine_history';
  static const _trackingStartKey = 'dose_tracking_started_at';

  static const Duration missedGracePeriod = Duration(minutes: 60);

  DateTime? _trackingStartedAt;

  Future<void> init() async {
    final savedStart = StorageService.instance.getString(_trackingStartKey);

    if (savedStart == null || savedStart.isEmpty) {
      final now = DateTime.now();

      await StorageService.instance.setString(
        _trackingStartKey,
        now.toIso8601String(),
      );

      _trackingStartedAt = now;
    } else {
      _trackingStartedAt = DateTime.tryParse(savedStart);
    }

    await reconcileMissedDoses();
  }

  List<Medicine> getMedicines() => StorageService.instance
      .getJsonList(_medKey)
      .map(Medicine.fromJson)
      .toList();

  Medicine? getMedicineById(String id) {
    for (final m in getMedicines()) {
      if (m.id == id) return m;
    }
    return null;
  }

  Future<void> _save(List<Medicine> list) =>
      StorageService.instance.setJsonList(
        _medKey,
        list.map((m) => m.toJson()).toList(),
      );

  Future<Medicine> addMedicine({
    required String name,
    required String dosage,
    required String frequency,
    required String startDate,
    String? endDate,
    required String reminderTime,
    List<String>? reminderTimes,
    String notes = '',
  }) async {
    final times =
        reminderTimes ?? (reminderTime.isEmpty ? <String>[] : [reminderTime]);

    final m = Medicine(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      dosage: dosage,
      frequency: frequency,
      startDate: startDate,
      endDate: endDate,
      reminderTime: times.isNotEmpty ? times.first : reminderTime,
      reminderTimes: times,
      notes: notes,
    );

    final list = getMedicines()..add(m);
    await _save(list);

    return m;
  }

  Future<void> updateMedicine(Medicine updated) async {
    final list = getMedicines();
    final i = list.indexWhere((m) => m.id == updated.id);

    if (i < 0) {
      throw StateError('Medicine not found.');
    }

    list[i] = updated;
    await _save(list);
  }

  int _notificationId(String value) {
    var hash = 0x811C9DC5;

    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }

    return hash;
  }

  DateTime? _getReminderDateTime(String startDate, String time) {
    final date = DateTime.tryParse(startDate);
    if (date == null) return null;

    final text = time.trim();

    final twelveHour = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(text);

    if (twelveHour != null) {
      var hour = int.parse(twelveHour.group(1)!);
      final minute = int.parse(twelveHour.group(2)!);
      final period = twelveHour.group(3)!.toUpperCase();

      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;

      if (hour > 23 || minute > 59) return null;

      return DateTime(
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );
    }

    final parts = text.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }

    return DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
  }

  Future<bool> toggleMedicine(String id, bool active) async {
    final medicine = getMedicineById(id);
    if (medicine == null) return false;

    await updateMedicine(medicine.copyWith(isActive: active));

    if (!active) {
      var allCancelled = true;

      for (var i = 0; i < 4; i++) {
        try {
          await NotificationService.instance.cancelReminder(
            _notificationId('${medicine.id}_dose_$i'),
          );
        } catch (e) {
          allCancelled = false;
        }
      }

      return allCancelled;
    }

    if (medicine.frequency == 'As needed' || medicine.reminderTimes.isEmpty) {
      return true;
    }

    final permissionGranted =
        await NotificationService.instance.requestPermission();

    if (!permissionGranted) return false;

    var allScheduled = true;

    for (var i = 0; i < medicine.reminderTimes.length; i++) {
      final reminderDate = _getReminderDateTime(
        medicine.startDate,
        medicine.reminderTimes[i],
      );

      if (reminderDate == null) {
        allScheduled = false;
        continue;
      }

      final success =
          await NotificationService.instance.scheduleDailyMedicineReminder(
        id: _notificationId('${medicine.id}_dose_$i'),
        medicineName: medicine.name,
        dateTime: reminderDate,
      );

      if (!success) {
        allScheduled = false;
      }
    }

    return allScheduled;
  }

  Future<void> deleteMedicine(String id) async {
    final list = getMedicines()..removeWhere((m) => m.id == id);
    await _save(list);

    // Existing History records are deliberately preserved.
  }

  List<HistoryEntry> getHistory() => StorageService.instance
      .getJsonList(_historyKey)
      .map(HistoryEntry.fromJson)
      .toList();

  Future<void> _saveHistory(List<HistoryEntry> list) {
    return StorageService.instance.setJsonList(
      _historyKey,
      list.map((e) => e.toJson()).toList(),
    );
  }

  DateTime? _parseReminderTime(String value, DateTime date) {
    final text = value.trim();

    final twelveHour = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(text);

    if (twelveHour != null) {
      var hour = int.parse(twelveHour.group(1)!);
      final minute = int.parse(twelveHour.group(2)!);
      final period = twelveHour.group(3)!.toUpperCase();

      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;

      if (hour > 23 || minute > 59) return null;

      return DateTime(
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );
    }

    final twentyFourHour = RegExp(
      r'^(\d{1,2}):(\d{2})$',
    ).firstMatch(text);

    if (twentyFourHour != null) {
      final hour = int.parse(twentyFourHour.group(1)!);
      final minute = int.parse(twentyFourHour.group(2)!);

      if (hour > 23 || minute > 59) return null;

      return DateTime(
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );
    }

    return null;
  }

  DateTime? _medicineStartDate(Medicine medicine) {
    return DateTime.tryParse(medicine.startDate);
  }

  DateTime? _medicineEndDate(Medicine medicine) {
    final value = medicine.endDate;

    if (value == null || value.isEmpty) return null;

    return DateTime.tryParse(value);
  }

  String _occurrenceKey(Medicine medicine, DateTime scheduled) {
    final date =
        '${scheduled.year}-${scheduled.month.toString().padLeft(2, '0')}-${scheduled.day.toString().padLeft(2, '0')}';

    final time =
        '${scheduled.hour.toString().padLeft(2, '0')}:${scheduled.minute.toString().padLeft(2, '0')}';

    return '${medicine.id}_${date}_$time';
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  List<DateTime> _scheduledTimesForDate(
    Medicine medicine,
    DateTime date,
  ) {
    if (medicine.reminderTimes.isEmpty || medicine.frequency == 'As needed') {
      return [];
    }

    final result = <DateTime>[];

    for (final time in medicine.reminderTimes) {
      final scheduled = _parseReminderTime(time, date);

      if (scheduled != null) {
        result.add(scheduled);
      }
    }

    return result;
  }

  Future<void> reconcileMissedDoses() async {
    final trackingStart = _trackingStartedAt;
    if (trackingStart == null) return;

    final now = DateTime.now();
    final today = _dateOnly(now);
    final firstTrackingDay = _dateOnly(trackingStart);

    final history = getHistory();

    final existingKeys = history
        .where((entry) => entry.occurrenceKey != null)
        .map((entry) => entry.occurrenceKey!)
        .toSet();

    var changed = false;

    for (final medicine in getMedicines()) {
      if (!medicine.isActive ||
          medicine.frequency == 'As needed' ||
          medicine.reminderTimes.isEmpty) {
        continue;
      }

      final medicineStart = _medicineStartDate(medicine);
      if (medicineStart == null) continue;

      final medicineEnd = _medicineEndDate(medicine);

      var date = _dateOnly(medicineStart);

      if (date.isBefore(firstTrackingDay)) {
        date = firstTrackingDay;
      }

      while (!date.isAfter(today)) {
        if (medicineEnd != null && date.isAfter(_dateOnly(medicineEnd))) {
          break;
        }

        final scheduledTimes = _scheduledTimesForDate(medicine, date);

        for (final scheduled in scheduledTimes) {
          if (scheduled.isBefore(trackingStart)) continue;

          final dueTime = scheduled.add(missedGracePeriod);
          if (dueTime.isAfter(now)) continue;

          final key = _occurrenceKey(medicine, scheduled);
          if (existingKeys.contains(key)) continue;

          history.insert(
            0,
            HistoryEntry(
              id: DateTime.now().microsecondsSinceEpoch.toString() +
                  history.length.toString(),
              medicineId: medicine.id,
              medicineName: medicine.name,
              dateTime: now.toIso8601String(),
              status: 'Missed',
              scheduledDateTime: scheduled.toIso8601String(),
              occurrenceKey: key,
            ),
          );

          existingKeys.add(key);
          changed = true;
        }

        date = date.add(const Duration(days: 1));
      }
    }

    if (changed) {
      await _saveHistory(history);
    }
  }

  HistoryEntry? _findMatchingOccurrence(
    Medicine medicine,
    DateTime now,
    List<HistoryEntry> history,
  ) {
    final earliest = now.subtract(const Duration(hours: 24));
    final trackingStart = _trackingStartedAt;

    if (trackingStart == null) return null;

    final start = _medicineStartDate(medicine);
    if (start == null) return null;

    final end = _medicineEndDate(medicine);

    final fromDate = _dateOnly(
      start.isAfter(earliest) ? start : earliest,
    );

    final toDate = _dateOnly(now);

    HistoryEntry? bestEntry;
    DateTime? bestScheduled;

    var date = fromDate;

    while (!date.isAfter(toDate)) {
      if (end != null && date.isAfter(_dateOnly(end))) break;

      for (final scheduled in _scheduledTimesForDate(medicine, date)) {
        if (scheduled.isAfter(now) ||
            scheduled.isBefore(earliest) ||
            scheduled.isBefore(trackingStart)) {
          continue;
        }

        final key = _occurrenceKey(medicine, scheduled);

        final existing = history.where(
          (entry) => entry.occurrenceKey == key,
        );

        final entry = existing.isEmpty ? null : existing.first;

        if (entry != null && entry.status == 'Taken') {
          continue;
        }

        if (bestScheduled == null || scheduled.isAfter(bestScheduled)) {
          bestScheduled = scheduled;

          bestEntry = entry ??
              HistoryEntry(
                id: '',
                medicineId: medicine.id,
                medicineName: medicine.name,
                dateTime: '',
                status: '',
                scheduledDateTime: scheduled.toIso8601String(),
                occurrenceKey: key,
              );
        }
      }

      date = date.add(const Duration(days: 1));
    }

    return bestEntry;
  }

  Future<void> recordAction(
    Medicine medicine,
    String status,
  ) async {
    if (status != 'Taken' && status != 'Missed') {
      throw ArgumentError('Invalid medicine history status.');
    }

    final history = getHistory();
    final now = DateTime.now();

    final match = _findMatchingOccurrence(
      medicine,
      now,
      history,
    );

    if (match != null) {
      final index = history.indexWhere(
        (entry) => entry.occurrenceKey == match.occurrenceKey,
      );

      if (index >= 0) {
        if (history[index].status == 'Taken') return;

        history[index] = HistoryEntry(
          id: history[index].id,
          medicineId: medicine.id,
          medicineName: medicine.name,
          dateTime: now.toIso8601String(),
          status: status,
          scheduledDateTime: match.scheduledDateTime,
          occurrenceKey: match.occurrenceKey,
        );
      } else {
        history.insert(
          0,
          HistoryEntry(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            medicineId: medicine.id,
            medicineName: medicine.name,
            dateTime: now.toIso8601String(),
            status: status,
            scheduledDateTime: match.scheduledDateTime,
            occurrenceKey: match.occurrenceKey,
          ),
        );
      }

      await _saveHistory(history);
      return;
    }

    history.insert(
      0,
      HistoryEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        medicineId: medicine.id,
        medicineName: medicine.name,
        dateTime: now.toIso8601String(),
        status: status,
      ),
    );

    await _saveHistory(history);
  }
}
