part of 'camera_flow_bloc.dart';

enum CameraFlowStep {
  clubSelection,
  loadingKids,
  clubSelected,
  camera,
  captured,
  recognizing,
  summary,
}

class CameraFlowState extends Equatable {
  final CameraFlowStep step;
  final ClassModel? selectedClass;
  final List<Child> children;
  final Set<String> recognizedUuids;
  final String? lastCapturedPath;
  final String? recognizeError;
  final String? error;

  const CameraFlowState({
    this.step = CameraFlowStep.clubSelection,
    this.selectedClass,
    this.children = const [],
    this.recognizedUuids = const {},
    this.lastCapturedPath,
    this.recognizeError,
    this.error,
  });

  Set<String> get childKbUuids =>
      children.map((c) => c.kbUuid).whereType<String>().toSet();

  CameraFlowState copyWith({
    CameraFlowStep? step,
    ClassModel? selectedClass,
    List<Child>? children,
    Set<String>? recognizedUuids,
    Object? lastCapturedPath = _omit,
    Object? recognizeError = _omit,
    Object? error = _omit,
  }) {
    return CameraFlowState(
      step: step ?? this.step,
      selectedClass: selectedClass ?? this.selectedClass,
      children: children ?? this.children,
      recognizedUuids: recognizedUuids ?? this.recognizedUuids,
      lastCapturedPath: lastCapturedPath == _omit ? this.lastCapturedPath : lastCapturedPath as String?,
      recognizeError: recognizeError == _omit ? this.recognizeError : recognizeError as String?,
      error: error == _omit ? this.error : error as String?,
    );
  }

  @override
  List<Object?> get props => [
        step,
        selectedClass,
        children,
        List.from(recognizedUuids)..sort(),
        lastCapturedPath,
        recognizeError,
        error,
      ];
}
