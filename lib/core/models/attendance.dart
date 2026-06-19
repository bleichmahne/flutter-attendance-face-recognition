import 'package:equatable/equatable.dart';

//swagger: /attendances - monthly attendance tracking per class
class Attendance extends Equatable {
  final int? id;
  final String? kbUuid;
  final int? classId;
  final int? customerId;
  final int? month;
  final int? year;
  final bool? isSecondary;
  final int? hVisitHistoryStatusId;
  final String? created;
  final String? updated;

  const Attendance({
    this.id,
    this.kbUuid,
    this.classId,
    this.customerId,
    this.month,
    this.year,
    this.isSecondary,
    this.hVisitHistoryStatusId,
    this.created,
    this.updated,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as int?,
      kbUuid: json['kb_uuid'] as String?,
      classId: json['class_id'] as int?,
      customerId: json['customer_id'] as int?,
      month: json['month'] as int?,
      year: json['year'] as int?,
      isSecondary: json['is_secondary'] as bool?,
      hVisitHistoryStatusId: json['h_visit_history_status_id'] as int?,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (kbUuid != null) 'kb_uuid': kbUuid,
      if (classId != null) 'class_id': classId,
      if (customerId != null) 'customer_id': customerId,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
      if (isSecondary != null) 'is_secondary': isSecondary,
      if (hVisitHistoryStatusId != null) 'h_visit_history_status_id': hVisitHistoryStatusId,
      if (created != null) 'created': created,
      if (updated != null) 'updated': updated,
    };
  }

  @override
  List<Object?> get props => [id, kbUuid, classId, customerId, month, year, isSecondary, hVisitHistoryStatusId, created, updated];
}
