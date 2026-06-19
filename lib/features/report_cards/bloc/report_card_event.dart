part of 'report_card_bloc.dart';

abstract class ReportCardEvent extends Equatable {
  const ReportCardEvent();

  @override
  List<Object?> get props => [];
}

class LoadReportCards extends ReportCardEvent {
  const LoadReportCards();
}

class RefreshReportCards extends ReportCardEvent {
  const RefreshReportCards();
}

