import 'package:equatable/equatable.dart';

class FaceRecognitionResult extends Equatable {
  final bool recognized;
  final String? uuid;
  final double confidence;
  final double? threshold;
  final String? message;

  const FaceRecognitionResult({
    required this.recognized,
    this.uuid,
    required this.confidence,
    this.threshold,
    this.message,
  });

  factory FaceRecognitionResult.fromJson(Map<String, dynamic> json) {
    return FaceRecognitionResult(
      recognized: json['recognized'] as bool? ?? false,
      uuid: json['uuid'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      threshold: (json['threshold'] as num?)?.toDouble(),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recognized': recognized,
      'uuid': uuid,
      'confidence': confidence,
      if (threshold != null) 'threshold': threshold,
      if (message != null) 'message': message,
    };
  }

  @override
  List<Object?> get props => [recognized, uuid, confidence, threshold, message];
}
