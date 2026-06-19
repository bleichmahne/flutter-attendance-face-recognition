import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/models/recognition_log.dart';
import '../../../core/models/visit_history.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_storage_service.dart';
import '../../../core/services/face_recognition_service.dart';

part 'child_detail_event.dart';
part 'child_detail_state.dart';

class ChildDetailBloc extends Bloc<ChildDetailEvent, ChildDetailState> {
  final ApiService apiService;
  final FaceRecognitionService faceService;
  final AuthStorageService authStorage;

  ChildDetailBloc({
    required this.apiService,
    required this.faceService,
    required this.authStorage,
  }) : super(const ChildDetailState()) {
    on<LoadChildDetail>(_onLoadChildDetail);
    on<RecognizeChild>(_onRecognizeChild);
    on<RefreshVisitHistories>(_onRefreshVisitHistories);
    on<ResetRecognition>(_onResetRecognition);
  }

  Future<void> _onLoadChildDetail(
    LoadChildDetail event,
    Emitter<ChildDetailState> emit,
  ) async {
    emit(state.copyWith(
      historyLoading: true,
      historyError: null,
      kidPhotoLoading: event.fetchKidPhoto && event.childKbUuid != null,
    ));
    try {
      final results = await Future.wait([
        apiService.getVisitHistoriesByChildId(event.childId),
        if (event.childKbUuid != null)
          apiService.getRecognitionLogsByUuid(event.childKbUuid!),
      ]);
      final histories = results[0] as List<VisitHistory>;
      final logs = results.length > 1 ? results[1] as List<RecognitionLog> : <RecognitionLog>[];
      emit(state.copyWith(
        visitHistories: histories,
        recognitionLogs: logs,
        historyLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        historyLoading: false,
        historyError: e.toString(),
      ));
    }

    if (event.fetchKidPhoto && event.childKbUuid != null) {
      final url = await faceService.getFirstRegistrationPhotoUrl(event.childKbUuid!);
      emit(state.copyWith(
        kidPhotoUrl: url,
        clearKidPhotoUrl: url == null,
        kidPhotoLoading: false,
      ));
    }
  }

  Future<void> _onRecognizeChild(
    RecognizeChild event,
    Emitter<ChildDetailState> emit,
  ) async {
    emit(state.copyWith(recognizing: true, clearRecognizedMatch: true));
    try {
      final user = await authStorage.getUser();
      if (user == null) {
        emit(state.copyWith(
          recognizing: false,
          recognizedMatch: false,
          recognitionError: 'Missing credentials',
        ));
        return;
      }
      //per backend contract: /verify password field carries the user's kbUuid
      final result = await faceService.verify(
        event.photo,
        uuid: event.childKbUuid,
        username: user.username,
        password: user.kbUuid,
        sectionId: event.sectionId,
      );
      //refresh recognition logs
      List<RecognitionLog> updatedLogs = state.recognitionLogs;
      try {
        updatedLogs = await apiService.getRecognitionLogsByUuid(event.childKbUuid);
      } catch (_) {}
      emit(state.copyWith(
        recognizing: false,
        recognizedMatch: result.isVerified,
        recognitionLogs: updatedLogs,
      ));
    } catch (e) {
      emit(state.copyWith(
        recognizing: false,
        recognizedMatch: false,
        recognitionError: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshVisitHistories(
    RefreshVisitHistories event,
    Emitter<ChildDetailState> emit,
  ) async {
    emit(state.copyWith(historyLoading: true, historyError: null));
    try {
      final results = await Future.wait([
        apiService.getVisitHistoriesByChildId(event.childId),
        if (event.childKbUuid != null)
          apiService.getRecognitionLogsByUuid(event.childKbUuid!),
      ]);
      final histories = results[0] as List<VisitHistory>;
      final logs = results.length > 1 ? results[1] as List<RecognitionLog> : <RecognitionLog>[];
      emit(state.copyWith(
        visitHistories: histories,
        recognitionLogs: logs,
        historyLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        historyLoading: false,
        historyError: e.toString(),
      ));
    }
  }

  void _onResetRecognition(
    ResetRecognition event,
    Emitter<ChildDetailState> emit,
  ) {
    emit(state.copyWith(
      clearRecognizedMatch: true,
      recognitionError: null,
    ));
  }
}
