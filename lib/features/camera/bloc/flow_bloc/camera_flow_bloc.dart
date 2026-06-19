import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/models/child.dart';
import '../../../../core/models/class_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_storage_service.dart';
import '../../../../core/services/face_recognition_service.dart';

part 'camera_flow_event.dart';
part 'camera_flow_state.dart';

const _omit = Object();

class CameraFlowBloc extends Bloc<CameraFlowEvent, CameraFlowState> {
  final ApiService apiService;
  final FaceRecognitionService faceRecognitionService;
  final AuthStorageService authStorage;

  CameraFlowBloc({
    required this.apiService,
    required this.faceRecognitionService,
    required this.authStorage,
  }) : super(const CameraFlowState()) {
    on<CameraFlowSelectClub>(_onSelectClub);
    on<CameraFlowStartCamera>(_onStartCamera);
    on<CameraFlowPhotoCaptured>(_onPhotoCaptured);
    on<CameraFlowUsePhotoAndRecognize>(_onUsePhotoAndRecognize);
    on<CameraFlowTakeNext>(_onTakeNext);
    on<CameraFlowFinishSession>(_onFinishSession);
    on<CameraFlowNewSession>(_onNewSession);
    on<CameraFlowReset>(_onReset);
    on<CameraFlowChangeClub>(_onChangeClub);
  }

  Future<void> _onSelectClub(
    CameraFlowSelectClub event,
    Emitter<CameraFlowState> emit,
  ) async {
    final classId = event.classItem.id;
    if (classId == null) return;
    emit(state.copyWith(
      step: CameraFlowStep.loadingKids,
      selectedClass: event.classItem,
      children: [],
      recognizedUuids: {},
    ));
    try {
      final list = await apiService.getChildrenInClass(classId);
      emit(state.copyWith(
        step: CameraFlowStep.clubSelected,
        children: list,
      ));
    } catch (e) {
      emit(state.copyWith(
        step: CameraFlowStep.clubSelection,
        error: e.toString(),
      ));
    }
  }

  void _onStartCamera(
    CameraFlowStartCamera event,
    Emitter<CameraFlowState> emit,
  ) {
    emit(state.copyWith(
      step: CameraFlowStep.camera,
      recognizedUuids: {},
      lastCapturedPath: null,
      recognizeError: null,
    ));
  }

  void _onPhotoCaptured(
    CameraFlowPhotoCaptured event,
    Emitter<CameraFlowState> emit,
  ) {
    emit(state.copyWith(
      step: CameraFlowStep.captured,
      lastCapturedPath: event.imagePath,
      recognizeError: null,
    ));
  }

  Future<void> _onUsePhotoAndRecognize(
    CameraFlowUsePhotoAndRecognize event,
    Emitter<CameraFlowState> emit,
  ) async {
    emit(state.copyWith(
      step: CameraFlowStep.recognizing,
      recognizeError: null,
    ));
    try {
      //same auth shape as /verify: username = user.username, password = user.kbUuid
      final user = await authStorage.getUser();
      final sectionId = state.selectedClass?.id;
      if (user == null || sectionId == null) {
        emit(state.copyWith(
          step: CameraFlowStep.captured,
          recognizeError: 'missing credentials or class',
        ));
        return;
      }
      final result = await faceRecognitionService.recognize(
        File(event.imagePath),
        username: user.username,
        password: user.kbUuid,
        sectionId: sectionId,
        threshold: 0.5,
      );
      final childKbUuids = state.childKbUuids;
      final newRecognized = Set<String>.from(state.recognizedUuids);
      if (result.recognized &&
          result.uuid != null &&
          childKbUuids.contains(result.uuid)) {
        newRecognized.add(result.uuid!);
      }
      emit(state.copyWith(
        step: CameraFlowStep.captured,
        recognizedUuids: newRecognized,
      ));
    } catch (e) {
      emit(state.copyWith(
        step: CameraFlowStep.captured,
        recognizeError: e.toString(),
      ));
    }
  }

  void _onTakeNext(
    CameraFlowTakeNext event,
    Emitter<CameraFlowState> emit,
  ) {
    emit(state.copyWith(
      step: CameraFlowStep.camera,
      lastCapturedPath: null,
      recognizeError: null,
    ));
  }

  void _onFinishSession(
    CameraFlowFinishSession event,
    Emitter<CameraFlowState> emit,
  ) {
    emit(state.copyWith(
      step: CameraFlowStep.summary,
      lastCapturedPath: null,
    ));
  }

  void _onNewSession(
    CameraFlowNewSession event,
    Emitter<CameraFlowState> emit,
  ) {
    emit(const CameraFlowState());
  }

  void _onReset(
    CameraFlowReset event,
    Emitter<CameraFlowState> emit,
  ) {
    emit(const CameraFlowState());
  }

  void _onChangeClub(
    CameraFlowChangeClub event,
    Emitter<CameraFlowState> emit,
  ) {
    emit(state.copyWith(
      step: CameraFlowStep.clubSelection,
      selectedClass: null,
      children: [],
      recognizedUuids: {},
    ));
  }
}
