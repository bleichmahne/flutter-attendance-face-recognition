import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/models/face_recognition_user.dart';
import '../../../core/models/photo_update_result.dart';
import '../../../core/services/face_recognition_service.dart';

part 'face_recognition_event.dart';
part 'face_recognition_state.dart';

//face API: create/delete/update face users; /recognize and /recognize/multi are backend-only, not used in app
class FaceRecognitionBloc extends Bloc<FaceRecognitionEvent, FaceRecognitionState> {
  final FaceRecognitionService service;

  FaceRecognitionBloc({required this.service}) : super(FaceRecognitionInitial()) {
    on<CreateFaceUser>(_onCreateFaceUser);
    on<DeleteFaceUser>(_onDeleteFaceUser);
    on<UpdateUserPhotos>(_onUpdateUserPhotos);
  }

  Future<void> _onCreateFaceUser(
    CreateFaceUser event,
    Emitter<FaceRecognitionState> emit,
  ) async {
    emit(FaceRecognitionLoading());
    try {
      final user = await service.createUser(event.uuid, event.photos);
      emit(FaceRecognitionUserCreated(user: user));
    } catch (e) {
      emit(FaceRecognitionError(message: e.toString()));
    }
  }

  Future<void> _onDeleteFaceUser(
    DeleteFaceUser event,
    Emitter<FaceRecognitionState> emit,
  ) async {
    emit(FaceRecognitionLoading());
    try {
      await service.deleteUser(event.uuid);
      emit(FaceRecognitionUserDeleted());
    } catch (e) {
      emit(FaceRecognitionError(message: e.toString()));
    }
  }

  Future<void> _onUpdateUserPhotos(
    UpdateUserPhotos event,
    Emitter<FaceRecognitionState> emit,
  ) async {
    emit(FaceRecognitionLoading());
    try {
      final result = await service.updateUserPhotos(
        event.uuid,
        event.photos,
        threshold: event.threshold,
      );
      emit(FaceRecognitionPhotosUpdated(result: result));
    } catch (e) {
      emit(FaceRecognitionError(message: e.toString()));
    }
  }
}
