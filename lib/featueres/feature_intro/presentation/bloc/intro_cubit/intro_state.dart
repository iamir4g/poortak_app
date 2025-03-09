// part of 'intro_cubit.dart';
//
// @immutable
// sealed class IntroState {}
//
// final class IntroInitial extends IntroState {}
part of 'intro_cubit.dart';

class IntroState {
  bool showGetStart;

  IntroState({required this.showGetStart});

  IntroState copyWith({
    bool? newShowGetStart,
  }){
    return IntroState(
        showGetStart: newShowGetStart ?? showGetStart
    );
  }
}