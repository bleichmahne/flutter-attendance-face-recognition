import 'package:equatable/equatable.dart';

class FaceRecognitionUser extends Equatable {
  final String uuid;
  final String? name;
  final int numPhotos;

  const FaceRecognitionUser({
    required this.uuid,
    this.name,
    required this.numPhotos,
  });

  factory FaceRecognitionUser.fromJson(Map<String, dynamic> json) {
    return FaceRecognitionUser(
      uuid: json['uuid'] as String,
      name: json['name'] as String?,
      numPhotos: json['num_photos'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'num_photos': numPhotos,
    };
  }

  @override
  List<Object?> get props => [uuid, name, numPhotos];
}
