part of 'sayareh_cubit.dart';

class SayarehState {
  SayarehDataStatus sayarehDataStatus;

  SayarehState({required this.sayarehDataStatus});

  SayarehState copyWith({SayarehDataStatus? sayarehDataStatus}) {
    return SayarehState(
        sayarehDataStatus: sayarehDataStatus ?? this.sayarehDataStatus);
  }

  SayarehState copyWithStorage({SayarehDataStatus? sayarehDataStatus}) {
    return SayarehState(
        sayarehDataStatus: sayarehDataStatus ?? this.sayarehDataStatus);
  }
}
