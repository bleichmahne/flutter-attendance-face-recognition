part of 'camera_flow_bloc.dart';

abstract class CameraFlowEvent extends Equatable {
  const CameraFlowEvent();

  @override
  List<Object?> get props => [];
}

class CameraFlowSelectClub extends CameraFlowEvent {
  final ClassModel classItem;

  const CameraFlowSelectClub(this.classItem);

  @override
  List<Object?> get props => [classItem];
}

class CameraFlowStartCamera extends CameraFlowEvent {
  const CameraFlowStartCamera();
}

class CameraFlowPhotoCaptured extends CameraFlowEvent {
  final String imagePath;

  const CameraFlowPhotoCaptured(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class CameraFlowUsePhotoAndRecognize extends CameraFlowEvent {
  final String imagePath;

  const CameraFlowUsePhotoAndRecognize(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class CameraFlowTakeNext extends CameraFlowEvent {
  const CameraFlowTakeNext();
}

class CameraFlowFinishSession extends CameraFlowEvent {
  const CameraFlowFinishSession();
}

class CameraFlowNewSession extends CameraFlowEvent {
  const CameraFlowNewSession();
}

class CameraFlowReset extends CameraFlowEvent {
  const CameraFlowReset();
}

class CameraFlowChangeClub extends CameraFlowEvent {
  const CameraFlowChangeClub();
}
