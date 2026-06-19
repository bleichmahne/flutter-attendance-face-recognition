import 'package:equatable/equatable.dart';

class PhotoUpdateResult extends Equatable {
  final String uuid;
  final String status;
  final int numPhotos;
  final double bestSimilarity;
  final double threshold;
  final String message;
  final List<double> similarities;

  const PhotoUpdateResult({
    required this.uuid,
    required this.status,
    required this.numPhotos,
    required this.bestSimilarity,
    required this.threshold,
    required this.message,
    this.similarities = const [],
  });

  factory PhotoUpdateResult.fromJson(Map<String, dynamic> json) {
    return PhotoUpdateResult(
      uuid: json['uuid'] as String,
      status: json['status'] as String,
      numPhotos: json['num_photos'] as int? ?? 0,
      bestSimilarity: (json['best_similarity'] as num?)?.toDouble() ?? 0.0,
      threshold: (json['threshold'] as num?)?.toDouble() ?? 0.0,
      message: json['message'] as String? ?? '',
      similarities: (json['similarities'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
    );
  }

  bool get isUpdated => status == 'updated';

  @override
  List<Object?> get props =>
      [uuid, status, numPhotos, bestSimilarity, threshold, message, similarities];
}
