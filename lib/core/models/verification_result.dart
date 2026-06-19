import 'package:equatable/equatable.dart';

//face API: POST /verify response (1:1 verification)
class VerificationResult extends Equatable {
  final String status;
  final String uuid;
  final double confidence;
  final double threshold;
  final String message;
  final bool? notificationSent;

  const VerificationResult({
    required this.status,
    required this.uuid,
    required this.confidence,
    required this.threshold,
    required this.message,
    this.notificationSent,
  });

  bool get isVerified => status == 'ok';

  factory VerificationResult.fromJson(Map<String, dynamic> json) {
    return VerificationResult(
      status: json['status'] as String,
      uuid: json['uuid'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      threshold: (json['threshold'] as num).toDouble(),
      message: json['message'] as String,
      notificationSent: json['notification_sent'] as bool?,
    );
  }

  @override
  List<Object?> get props => [status, uuid, confidence, threshold, message, notificationSent];
}
