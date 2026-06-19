part of 'child_detail_bloc.dart';

abstract class ChildDetailEvent extends Equatable {
  const ChildDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadChildDetail extends ChildDetailEvent {
  final int childId;
  final int classId;
  final String? childKbUuid;
  final bool fetchKidPhoto;

  const LoadChildDetail({
    required this.childId,
    required this.classId,
    this.childKbUuid,
    this.fetchKidPhoto = false,
  });

  @override
  List<Object?> get props => [childId, classId, childKbUuid, fetchKidPhoto];
}

class RecognizeChild extends ChildDetailEvent {
  final File photo;
  final String childKbUuid;
  final int sectionId;

  const RecognizeChild({required this.photo, required this.childKbUuid, required this.sectionId});

  @override
  List<Object?> get props => [photo, childKbUuid, sectionId];
}

class RefreshVisitHistories extends ChildDetailEvent {
  final int childId;
  final int classId;
  final String? childKbUuid;

  const RefreshVisitHistories({required this.childId, required this.classId, this.childKbUuid});

  @override
  List<Object?> get props => [childId, classId, childKbUuid];
}

class ResetRecognition extends ChildDetailEvent {
  const ResetRecognition();
}
