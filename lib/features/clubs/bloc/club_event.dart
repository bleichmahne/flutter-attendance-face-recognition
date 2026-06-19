part of 'club_bloc.dart';

abstract class ClubEvent extends Equatable {
  const ClubEvent();

  @override
  List<Object?> get props => [];
}

class LoadClubs extends ClubEvent {
  const LoadClubs();
}

class RefreshClubs extends ClubEvent {
  const RefreshClubs();
}

