part of 'report_card_bloc.dart';

abstract class ReportCardState extends Equatable {
  const ReportCardState();

  @override
  List<Object?> get props => [];
}

class ReportCardInitial extends ReportCardState {}

class ReportCardLoading extends ReportCardState {}

class ReportCardLoaded extends ReportCardState {
  final List<VisitHistory> visitHistories;

  const ReportCardLoaded({required this.visitHistories});

  @override
  List<Object?> get props => [visitHistories];
}

class ReportCardError extends ReportCardState {
  final String message;

  const ReportCardError({required this.message});

  @override
  List<Object?> get props => [message];
}

