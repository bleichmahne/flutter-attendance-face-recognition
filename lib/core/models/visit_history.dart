import 'package:equatable/equatable.dart';

///visit history from API (Swagger models.VisitHistory)
class VisitHistory extends Equatable {
  final int? id;
  final int? attendanceId;
  final String? classDate;
  final String? created;
  final String? createdDt;
  final int? hVisitResultId;
  final bool? isFarFaces;
  final String? kbUuid;
  final int? subscriptionId;
  final String? updated;

  const VisitHistory({
    this.id,
    this.attendanceId,
    this.classDate,
    this.created,
    this.createdDt,
    this.hVisitResultId,
    this.isFarFaces,
    this.kbUuid,
    this.subscriptionId,
    this.updated,
  });

  factory VisitHistory.fromJson(Map<String, dynamic> json) {
    return VisitHistory(
      id: json['id'] as int?,
      attendanceId: json['attendance_id'] as int?,
      classDate: json['class_date'] as String?,
      created: json['created'] as String?,
      createdDt: json['created_dt'] as String?,
      hVisitResultId: json['h_visit_result_id'] as int?,
      isFarFaces: json['is_far_faces'] as bool?,
      kbUuid: json['kb_uuid'] as String?,
      subscriptionId: json['subscription_id'] as int?,
      updated: json['updated'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (attendanceId != null) 'attendance_id': attendanceId,
      if (classDate != null) 'class_date': classDate,
      if (created != null) 'created': created,
      if (createdDt != null) 'created_dt': createdDt,
      if (hVisitResultId != null) 'h_visit_result_id': hVisitResultId,
      if (isFarFaces != null) 'is_far_faces': isFarFaces,
      if (kbUuid != null) 'kb_uuid': kbUuid,
      if (subscriptionId != null) 'subscription_id': subscriptionId,
      if (updated != null) 'updated': updated,
    };
  }

  @override
  List<Object?> get props => [
        id,
        attendanceId,
        classDate,
        created,
        createdDt,
        hVisitResultId,
        isFarFaces,
        kbUuid,
        subscriptionId,
        updated,
      ];
}
