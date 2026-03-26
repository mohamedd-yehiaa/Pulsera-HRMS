import 'package:pulsera/models/company_model.dart';

/// Encapsulates all schedule-related parameters needed for
/// time-based attendance validation.
class WorkScheduleConfig {
  /// Working day start time in "HH:mm" format (e.g. "09:00").
  final String workStartTime;

  /// Working day end time in "HH:mm" format (e.g. "17:00").
  final String workEndTime;

  /// Minutes after [workStartTime] that are still considered on-time.
  final int gracePeriodMinutes;

  /// Minutes before [workStartTime] that check-in is allowed.
  final int earlyAllowanceMinutes;

  /// Minutes after [workStartTime] beyond which check-in is "very late".
  final int lateCutoffMinutes;

  /// Minimum work hours per day; below this flags "insufficient hours".
  final int minimumWorkHours;

  const WorkScheduleConfig({
    required this.workStartTime,
    required this.workEndTime,
    this.gracePeriodMinutes = 15,
    this.earlyAllowanceMinutes = 30,
    this.lateCutoffMinutes = 120,
    this.minimumWorkHours = 6,
  });

  /// Builds a config from an existing [CompanyModel], falling back
  /// to sensible defaults when fields are null.
  factory WorkScheduleConfig.fromCompanyModel(CompanyModel company) {
    return WorkScheduleConfig(
      workStartTime: company.startTime ?? '09:00',
      workEndTime: company.endTime ?? '17:00',
      gracePeriodMinutes: company.gracePeriodMinutes ?? 15,
      earlyAllowanceMinutes: company.earlyAllowanceMinutes ?? 30,
      lateCutoffMinutes: company.lateCutoffMinutes ?? 120,
      minimumWorkHours: company.minimumWorkHours ?? 6,
    );
  }
}
