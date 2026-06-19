import 'package:equatable/equatable.dart';

//swagger: /recognition-logs - tracks face recognition events
class RecognitionLog extends Equatable {
  final int? id;
  final String? kbUuid;
  final String? uuid;
  final int? sectionId;
  final bool? recognized;
  final double? confidence;
  final double? threshold;
  final String? message;
  final String timestamp;
  final String? createdAt;

  const RecognitionLog({
    this.id,
    this.kbUuid,
    this.uuid,
    this.sectionId,
    this.recognized,
    this.confidence,
    this.threshold,
    this.message,
    required this.timestamp,
    this.createdAt,
  });

  factory RecognitionLog.fromJson(Map<String, dynamic> json) {
    return RecognitionLog(
      id: json['id'] as int?,
      kbUuid: json['kb_uuid'] as String?,
      uuid: json['uuid'] as String?,
      sectionId: json['section_id'] as int?,
      recognized: json['recognized'] as bool?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      threshold: (json['threshold'] as num?)?.toDouble(),
      message: json['message'] as String?,
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (kbUuid != null) 'kb_uuid': kbUuid,
      if (uuid != null) 'uuid': uuid,
      if (sectionId != null) 'section_id': sectionId,
      if (recognized != null) 'recognized': recognized,
      if (confidence != null) 'confidence': confidence,
      if (threshold != null) 'threshold': threshold,
      if (message != null) 'message': message,
      'timestamp': timestamp,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [id, kbUuid, uuid, sectionId, recognized, confidence, threshold, message, timestamp, createdAt];
}
