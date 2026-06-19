part of 'face_recognition_bloc.dart';

abstract class FaceRecognitionEvent extends Equatable {
  const FaceRecognitionEvent();

  @override
  List<Object?> get props => [];
}

class CreateFaceUser extends FaceRecognitionEvent {
  final String uuid;
  final List<File> photos;

  const CreateFaceUser({
    required this.uuid,
    required this.photos,
  });

  @override
  List<Object?> get props => [uuid, photos];
}

class DeleteFaceUser extends FaceRecognitionEvent {
  final String uuid;

  const DeleteFaceUser({required this.uuid});

  @override
  List<Object?> get props => [uuid];
}

class UpdateUserPhotos extends FaceRecognitionEvent {
  final String uuid;
  final List<File> photos;
  final double threshold;

  const UpdateUserPhotos({
    required this.uuid,
    required this.photos,
    this.threshold = 0.15,
  });

  @override
  List<Object?> get props => [uuid, photos, threshold];
}
