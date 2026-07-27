part of 'contact_us_bloc.dart';

sealed class ContactUsState extends Equatable {
  const ContactUsState();

  @override
  List<Object?> get props => [];
}

final class ContactUsInitial extends ContactUsState {}

final class ContactUsLoading extends ContactUsState {}

final class ContactUsSuccess extends ContactUsState {
  final ContactUsInfo info;

  const ContactUsSuccess({required this.info});

  @override
  List<Object?> get props => [info];
}

final class ContactUsError extends ContactUsState {
  final String message;

  const ContactUsError({required this.message});

  @override
  List<Object?> get props => [message];
}
