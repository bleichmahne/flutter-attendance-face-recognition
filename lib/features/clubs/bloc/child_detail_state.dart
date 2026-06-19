part of 'child_detail_bloc.dart';

class ChildDetailState extends Equatable {
  final List<VisitHistory> visitHistories;
  final List<RecognitionLog> recognitionLogs;
  final bool historyLoading;
  final String? historyError;
  final bool recognizing;
  final bool? recognizedMatch;
  final String? recognitionError;
  final String? kidPhotoUrl;
  final bool kidPhotoLoading;

  const ChildDetailState({
    this.visitHistories = const [],
    this.recognitionLogs = const [],
    this.historyLoading = false,
    this.historyError,
    this.recognizing = false,
    this.recognizedMatch,
    this.recognitionError,
    this.kidPhotoUrl,
    this.kidPhotoLoading = false,
  });

  ChildDetailState copyWith({
    List<VisitHistory>? visitHistories,
    List<RecognitionLog>? recognitionLogs,
    bool? historyLoading,
    String? historyError,
    bool? recognizing,
    bool? recognizedMatch,
    bool clearRecognizedMatch = false,
    String? recognitionError,
    String? kidPhotoUrl,
    bool clearKidPhotoUrl = false,
    bool? kidPhotoLoading,
  }) {
    return ChildDetailState(
      visitHistories: visitHistories ?? this.visitHistories,
      recognitionLogs: recognitionLogs ?? this.recognitionLogs,
      historyLoading: historyLoading ?? this.historyLoading,
      historyError: historyError,
      recognizing: recognizing ?? this.recognizing,
      recognizedMatch: clearRecognizedMatch ? null : (recognizedMatch ?? this.recognizedMatch),
      recognitionError: recognitionError,
      kidPhotoUrl: clearKidPhotoUrl ? null : (kidPhotoUrl ?? this.kidPhotoUrl),
      kidPhotoLoading: kidPhotoLoading ?? this.kidPhotoLoading,
    );
  }

  @override
  List<Object?> get props => [
        visitHistories,
        recognitionLogs,
        historyLoading,
        historyError,
        recognizing,
        recognizedMatch,
        recognitionError,
        kidPhotoUrl,
        kidPhotoLoading,
      ];
}
